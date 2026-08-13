# The sqlite backend: one row per command in a zsh_history table.
#
#   zstyle ':zephyr:plugin:history:aux:sqlite' enable yes

_zsh_aux_hist_backends+=(sqlite)
_zsh_aux_hist_defaults[sqlite]="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history.db"

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

_zsh_aux_hist_sqlite_insert() {
  emulate -L zsh
  setopt local_options
  local db="$1"
  shift
  local -a vals=("$@")
  local q="'" i
  for i in {1..$#vals}; do
    vals[i]="'${vals[i]//$q/$q$q}'"
  done
  sqlite3 "$db" \
    "INSERT INTO zsh_history(sid,cwd,cmd,ret,pipestatus,start_ts,end_ts) VALUES(${(j:,:)vals});" \
    >/dev/null 2>&1
}
