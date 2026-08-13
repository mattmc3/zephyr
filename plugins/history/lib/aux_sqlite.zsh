# The sqlite backend: one row per command in a zsh_history table.
#
#   zstyle ':zephyr:plugin:history:aux:sqlite' enable yes
#
# A command is written twice: as it starts, and again when it finishes with the
# outcome. The two writes pair on (sid, start_ts), which the unique index enforces.

_zsh_aux_hist_backends+=(sqlite)
_zsh_aux_hist_defaults[sqlite]="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history.db"

# Waited out rather than lost when another shell is mid-write.
typeset -gi _zsh_aux_hist_sqlite_busy_ms=5000

# Schema changes go in a new migration function, numbered from the last one. Each
# runs once, tracked by the database's own user_version.
_zsh_aux_hist_sqlite_migration_0() {
  emulate -L zsh
  setopt local_options
  local db="$1"
  sqlite3 "$db" <<'SQL'
CREATE TABLE IF NOT EXISTS zsh_history (
  id         INTEGER PRIMARY KEY,
  sid        TEXT,
  cwd        TEXT,
  cmd        TEXT,
  ret        INTEGER,
  pipestatus TEXT,
  start_ts   REAL,
  end_ts     REAL
);
CREATE INDEX IF NOT EXISTS idx_zsh_history_start_ts ON zsh_history(start_ts DESC);
CREATE INDEX IF NOT EXISTS idx_zsh_history_cmd      ON zsh_history(cmd);
SQL
}

_zsh_aux_hist_sqlite_migration_1() {
  emulate -L zsh
  setopt local_options
  local db="$1"
  # The index pairs the two writes. duration is virtual: the timestamps already
  # hold it.
  sqlite3 "$db" <<'SQL'
CREATE UNIQUE INDEX IF NOT EXISTS idx_zsh_history_sid_start_ts ON zsh_history(sid, start_ts);
ALTER TABLE zsh_history ADD COLUMN duration REAL GENERATED ALWAYS AS (end_ts - start_ts) VIRTUAL;
SQL
}

_zsh_aux_hist_sqlite_init() {
  emulate -L zsh
  setopt local_options
  local db="$1" current_ver i

  mkdir -p "${db:h}" || return 1

  (( $+commands[sqlite3] )) || {
    printf 'zsh_aux_history: sqlite3 required for sqlite backend\n' >&2
    return 1
  }

  sqlite3 "$db" "PRAGMA journal_mode=WAL;" >/dev/null 2>&1 || return 1

  current_ver="$(sqlite3 "$db" 'PRAGMA user_version;' 2>/dev/null || echo 0)"

  for i in {0..10}; do
    (( i < current_ver )) && continue
    declare -f "_zsh_aux_hist_sqlite_migration_$i" >/dev/null || break
    "_zsh_aux_hist_sqlite_migration_$i" "$db" || return 1
    sqlite3 "$db" "PRAGMA user_version = $(( i + 1 ));" >/dev/null 2>&1 || return 1
  done
}

# Run SQL with named parameters, given as name/value pairs:
#   _zsh_aux_hist_sqlite_run "$db" 'UPDATE t SET a=@a WHERE id=@id' a "$a" id "$id"
# sqlite3 cannot bind from its command line, so values go through .parameter,
# escaped as a SQL literal and again for the dot-command parser.
_zsh_aux_hist_sqlite_run() {
  emulate -L zsh
  setopt local_options extended_glob pipe_fail

  local db="$1" sql="$2"
  shift 2

  (( $# % 2 == 0 )) || {
    printf 'zsh_aux_history: sqlite parameters must be name/value pairs\n' >&2
    return 2
  }

  # Checked before the pipeline: a `return` from inside it leaves only the
  # subshell, and the statement would run with the parameter unbound.
  local -a params=("$@")
  local -i i
  local name
  for (( i = 1; i <= $#params; i += 2 )); do
    name="${params[i]#@}"
    [[ "$name" == [A-Za-z_][A-Za-z0-9_]# ]] || {
      printf 'zsh_aux_history: invalid sqlite parameter: %s\n' "${params[i]}" >&2
      return 2
    }
    params[i]="@$name"
  done

  {
    printf '%s\n' '.parameter init'

    # Unquoted on purpose: quoting leaves the backslashes in the replacement, so a
    # quote comes out as \'\' instead of ''.
    local value
    for (( i = 1; i <= $#params; i += 2 )); do
      value=${params[i+1]//\'/\'\'}
      value=${value//\\/\\\\}
      value=${value//\"/\\\"}
      value=${value//$'\n'/\\n}
      value=${value//$'\r'/\\r}
      value=${value//$'\t'/\\t}
      printf ".parameter set %s \"'%s'\"\n" "${params[i]}" "$value"
    done
    printf 'PRAGMA busy_timeout=%d;\n%s\n;\n' "$_zsh_aux_hist_sqlite_busy_ms" "$sql"
  } | sqlite3 "$db" >/dev/null 2>&1
}

# The command as it starts, with no outcome yet. A fast command lets the finish
# write land first, so this must not blank what it recorded.
_zsh_aux_hist_sqlite_start() {
  _zsh_aux_hist_sqlite_run "$1" '
    INSERT INTO zsh_history(sid,cwd,cmd,start_ts) VALUES(@sid,@cwd,@cmd,@start_ts)
    ON CONFLICT(sid,start_ts) DO UPDATE SET cwd=excluded.cwd, cmd=excluded.cmd;' \
    @sid      "$2" \
    @cwd      "$3" \
    @cmd      "$4" \
    @start_ts "$5"
}

# How the command ended. The row is normally there already, but the writes are
# separate processes, so a miss inserts rather than drops.
_zsh_aux_hist_sqlite_insert() {
  # changes() is what the UPDATE just did, so the INSERT only runs on a miss.
  _zsh_aux_hist_sqlite_run "$1" '
    UPDATE zsh_history
       SET end_ts=@end_ts, ret=@ret, pipestatus=@pipes, cwd=COALESCE(cwd,@cwd)
     WHERE sid=@sid AND start_ts=@start_ts;
    INSERT INTO zsh_history(sid,cwd,cmd,ret,pipestatus,start_ts,end_ts)
    SELECT @sid,@cwd,@cmd,@ret,@pipes,@start_ts,@end_ts WHERE changes()=0;' \
    @sid      "$2" \
    @cwd      "$3" \
    @cmd      "$4" \
    @ret      "$5" \
    @pipes    "$6" \
    @start_ts "$7" \
    @end_ts   "$8"
}
