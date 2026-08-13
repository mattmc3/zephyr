#!/usr/bin/env bats
# Auxiliary history: every command recorded to a structured file beside HISTFILE.
#
# Command text is only ever a string handed to the hooks. Nothing here runs it.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

need_sqlite3() { command -v sqlite3 >/dev/null || skip "sqlite3 not installed"; }
need_jq() { command -v jq >/dev/null || skip "jq not installed"; }

# The zsh side of every test: the plugin, the helpers, and the given zstyles.
aux_session() {
  local styles="$1"; shift
  local body
  if (( $# )); then body="$*"; else body="$(cat)"; fi
  zephyr_zsh "
    $styles
    source \$ZEPHYR_HOME/lib/bootstrap.zsh
    source \$ZEPHYR_HOME/plugins/history/history.plugin.zsh
    source \$ZEPHYR_HOME/tests/bats/helpers/auxhist.zsh
    $body"
}

sqlite_on="zstyle ':zephyr:plugin:history:aux:sqlite' enable yes"
json_on="zstyle ':zephyr:plugin:history:aux:json' enable yes"

#
# Loading and dispatch
#

# With no backend on, the aux files are never sourced, so there is no hook and
# nothing in flight to wait for.
@test "neither backend runs unless it is enabled" {
  aux_session '' <<'EOS'
print "hooks: $+functions[_zsh_aux_hist_precmd]"
print "db: $([[ -e $(aux_db) ]] && print yes || print no)"
print "jsonl: $([[ -e $(aux_jsonl) ]] && print yes || print no)"
EOS
  assert_success
  assert_line "hooks: 0"
  assert_line "db: no"
  assert_line "jsonl: no"
}

@test "enabling one backend still loads the other, so a later zstyle works" {
  need_sqlite3
  need_jq
  aux_session "$sqlite_on" <<'EOS'
print "registered: ${(o)_zsh_aux_hist_backends}"
zstyle ':zephyr:plugin:history:aux:json' enable yes
aux_run 'echo late'
aux_wait 5 aux_lines 1
print "jsonl lines: $(wc -l < $(aux_jsonl) | tr -d ' ')"
EOS
  assert_success
  assert_line "registered: json sqlite"
  assert_line "jsonl lines: 1"
}

#
# sqlite: the two-phase write
#

@test "the start write records the command with no outcome yet" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
_zsh_aux_hist_preexec 'fake_sleep 30'
aux_wait 5 aux_rows 1
print "row: $(aux_sql "SELECT cmd, ifnull(ret, '-'), ifnull(end_ts, '-'), ifnull(duration, '-') FROM zsh_history;")"
EOS
  assert_success
  assert_line $'row: fake_sleep 30\t-\t-\t-'
}

@test "the finish write fills in the outcome, leaving one row" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
aux_run 'echo done' 3
aux_wait 5 aux_finished 1
print "rows: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
print "row: $(aux_sql 'SELECT cmd, ret, pipestatus, (end_ts > start_ts), (duration > 0) FROM zsh_history;')"
EOS
  assert_success
  assert_line "rows: 1"
  assert_line $'row: echo done\t3\t3\t1\t1'
}

# A fast command lets the finish write reach the database first. The row it
# inserts has to survive the start write that lands afterwards. Called directly,
# both writes are synchronous, so the order here is the whole point.
@test "a finish write that arrives first is not undone by the start write" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
_zsh_aux_hist_resolve sqlite
db=$REPLY
_zsh_aux_hist_sqlite_insert "$db" sid-1 /tmp 'echo race' 7 '7' 100.5 100.75
print "after finish: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
_zsh_aux_hist_sqlite_start "$db" sid-1 /tmp 'echo race' 100.5
print "rows: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
print "row: $(aux_sql 'SELECT cmd, ret, pipestatus, end_ts, duration FROM zsh_history;')"
EOS
  assert_success
  assert_line "after finish: 1"
  assert_line "rows: 1"
  assert_line $'row: echo race\t7\t7\t100.75\t0.25'
}

@test "each command gets its own row" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
aux_run 'echo one'
aux_run 'echo two'
aux_run 'echo three'
aux_wait 5 aux_finished 3
print "rows: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
print "cmds: $(aux_sql "SELECT group_concat(cmd, ',') FROM (SELECT cmd FROM zsh_history ORDER BY start_ts);")"
EOS
  assert_success
  assert_line "rows: 3"
  assert_line "cmds: echo one,echo two,echo three"
}

@test "cwd is where the command was launched, not where it finished" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
mkdir -p $HOME/launched $HOME/landed
cd $HOME/launched
_zsh_aux_hist_preexec 'cd ../landed'
cd $HOME/landed
_zsh_aux_hist_precmd
aux_wait 5 aux_finished 1
print "cwd: $(aux_sql 'SELECT cwd FROM zsh_history;')"
print "want: $HOME/launched"
EOS
  assert_success
  cwd="$(printf '%s\n' "$output" | sed -n 's/^cwd: //p')"
  want="$(printf '%s\n' "$output" | sed -n 's/^want: //p')"
  [[ "$cwd" == "$want" ]] || {
    echo "cwd was $cwd, wanted $want" >&2
    _dump_output
    return 1
  }
}

#
# sqlite: schema
#

@test "a new database gets the schema and the current version" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
_zsh_aux_hist_resolve sqlite
print "resolve: $?"
print "version: $(aux_sql 'PRAGMA user_version;')"
print "table: $(aux_sql "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='zsh_history';")"
print "index: $(aux_sql "SELECT count(*) FROM sqlite_master WHERE type='index' AND name='idx_zsh_history_sid_start_ts';")"
EOS
  assert_success
  assert_line "resolve: 0"
  assert_line "version: 2"
  assert_line "table: 1"
  assert_line "index: 1"
}

@test "preparing an already migrated database changes nothing" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
aux_run 'echo first'
aux_wait 5 aux_finished 1
_zsh_aux_hist_sqlite_init "$(aux_db)"
print "second init: $?"
print "version: $(aux_sql 'PRAGMA user_version;')"
print "rows: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
EOS
  assert_success
  assert_line "second init: 0"
  assert_line "version: 2"
  assert_line "rows: 1"
}

# Two commands recorded at the same instant in one session cannot both keep their
# row once the pairing index is unique. Better to stop than to drop history.
@test "a database that cannot take the unique index says so" {
  need_sqlite3
  db="$TEST_HOME/.local/share/zsh/zsh_history.db"
  mkdir -p "${db%/*}"
  sqlite3 "$db" <<'SQL'
CREATE TABLE zsh_history (id INTEGER PRIMARY KEY, sid TEXT, cwd TEXT, cmd TEXT,
  ret INTEGER, pipestatus TEXT, start_ts REAL, end_ts REAL);
PRAGMA user_version=1;
INSERT INTO zsh_history(sid,cmd,start_ts) VALUES('s','echo a',1.0),('s','echo b',1.0);
SQL
  aux_session "$sqlite_on" <<'EOS'
_zsh_aux_hist_resolve sqlite 2>/dev/null
print "resolve: $?"
print "rows kept: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
EOS
  assert_success
  assert_line "resolve: 1"
  assert_line "rows kept: 2"
}

@test "an existing v1 database keeps its rows and gains the duration column" {
  need_sqlite3
  db="$TEST_HOME/.local/share/zsh/zsh_history.db"
  mkdir -p "${db%/*}"
  sqlite3 "$db" <<'SQL'
CREATE TABLE zsh_history (id INTEGER PRIMARY KEY, sid TEXT, cwd TEXT, cmd TEXT,
  ret INTEGER, pipestatus TEXT, start_ts REAL, end_ts REAL);
PRAGMA user_version=1;
INSERT INTO zsh_history(sid,cwd,cmd,ret,pipestatus,start_ts,end_ts)
  VALUES('old','/tmp','echo legacy',0,'0',1.0,2.5);
SQL
  aux_session "$sqlite_on" <<'EOS'
aux_run 'echo fresh'
aux_wait 5 aux_finished 2
print "version: $(aux_sql 'PRAGMA user_version;')"
print "legacy: $(aux_sql "SELECT cmd, duration FROM zsh_history WHERE sid = 'old';")"
EOS
  assert_success
  assert_line "version: 2"
  assert_line $'legacy: echo legacy\t1.5'
}

#
# sqlite: parameter binding
#

@test "quotes, backslashes, tabs and newlines survive the round trip" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
val=$'it\'s "quoted" \\ back\tand\nnewline'
aux_run "$val"
aux_wait 5 aux_finished 1
got=$(sqlite3 $(aux_db) 'SELECT cmd FROM zsh_history;')
[[ $got == $val ]] && print "round trip: exact" || print "round trip: $got"
EOS
  assert_success
  assert_line "round trip: exact"
}

@test "a statement is not built from the value, so SQL in a command is inert" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
aux_run "echo '); DROP TABLE zsh_history; --"
aux_wait 5 aux_finished 1
print "table: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
print "cmd: $(aux_sql 'SELECT cmd FROM zsh_history;')"
EOS
  assert_success
  assert_line "table: 1"
  assert_line "cmd: echo '); DROP TABLE zsh_history; --"
}

@test "the runner rejects a bad parameter name and odd pairs" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
_zsh_aux_hist_resolve sqlite
_zsh_aux_hist_sqlite_run "$REPLY" 'SELECT 1' 'bad; name' x 2>/dev/null
print "bad name: $?"
_zsh_aux_hist_sqlite_run "$REPLY" 'SELECT 1' lonely 2>/dev/null
print "odd pairs: $?"
_zsh_aux_hist_sqlite_run "$REPLY" 'SELECT * FROM nosuchtable'
print "sql error: $?"
_zsh_aux_hist_sqlite_run "$REPLY" 'SELECT @a' @a hi
print "ok: $?"
EOS
  assert_success
  assert_line "bad name: 2"
  assert_line "odd pairs: 2"
  assert_line "sql error: 1"
  assert_line "ok: 0"
}

#
# json
#

# The json backend has no start write to queue, so its file cannot exist yet.
@test "json writes one object per finished command, and nothing before" {
  need_jq
  aux_session "$json_on" <<'EOS'
_zsh_aux_hist_preexec 'echo pending'
print "at start: $([[ -s $(aux_jsonl) ]] && print written || print empty)"
_zsh_aux_hist_precmd
aux_wait 5 aux_lines 1
print "at finish: $(jq -r '[.cmd, (.ret|tostring), (.end_ts > .start_ts|tostring)] | join(",")' $(aux_jsonl))"
EOS
  assert_success
  assert_line "at start: empty"
  assert_line "at finish: echo pending,0,true"
}

#
# What zsh itself would not store
#

# A skipped command leaves nothing for precmd to finish, which is decided in the
# hook itself. The kept command that follows is what the row count is waiting on.
@test "a leading space is skipped under hist_ignore_space" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
setopt hist_ignore_space
_zsh_aux_hist_preexec ' echo secret'
print "pending: $(aux_pending)"
aux_run 'echo kept'
aux_wait 5 aux_finished 1
print "rows: $(aux_sql 'SELECT count(*) FROM zsh_history;')"
print "cmd: $(aux_sql 'SELECT cmd FROM zsh_history;')"
EOS
  assert_success
  assert_line "pending: none"
  assert_line "rows: 1"
  assert_line "cmd: echo kept"
}

#
# Privacy
#

@test "the history files are readable only by their owner" {
  need_sqlite3
  need_jq
  aux_session "$sqlite_on
$json_on" <<'EOS'
aux_run 'echo private'
aux_wait 5 aux_finished 1
aux_wait 5 aux_lines 1
zmodload zsh/stat
zstat -H s -F '%OU' "$(aux_db)"
print "db: $s[mode]"
zstat -H s -F '%OU' "$(aux_jsonl)"
print "jsonl: $s[mode]"
EOS
  assert_success
  assert_line "db: -rw-------"
  assert_line "jsonl: -rw-------"
}

@test "an empty command line records nothing" {
  need_sqlite3
  aux_session "$sqlite_on" <<'EOS'
aux_run ''
print "pending: $(aux_pending)"
print "db: $([[ -e $(aux_db) ]] && print created || print absent)"
EOS
  assert_success
  assert_line "pending: none"
  assert_line "db: absent"
}

#
# Missing dependencies
#

@test "the sqlite backend gives up quietly when sqlite3 is missing" {
  aux_session "$sqlite_on" <<'EOS'
# A PATH with everything the backend needs except sqlite3 itself.
mkdir -p $HOME/stubbin
for c in mkdir touch; do ln -sf $commands[$c] $HOME/stubbin/$c; done
path=($HOME/stubbin)
_zsh_aux_hist_resolve sqlite
print "resolve: $?"
aux_run 'echo orphan'
print "shell still alive: yes"
EOS
  assert_success
  assert_line "resolve: 1"
  assert_line "shell still alive: yes"
  assert_output_contains "sqlite3 required for sqlite backend"
}

@test "the json backend gives up quietly when jq is missing" {
  aux_session "$json_on" <<'EOS'
# A PATH with everything the backend needs except jq itself.
mkdir -p $HOME/stubbin
for c in mkdir touch; do ln -sf $commands[$c] $HOME/stubbin/$c; done
path=($HOME/stubbin)
_zsh_aux_hist_resolve json
print "resolve: $?"
aux_run 'echo orphan'
print "shell still alive: yes"
EOS
  assert_success
  assert_line "resolve: 1"
  assert_line "shell still alive: yes"
  assert_output_contains "jq required for json backend"
}
