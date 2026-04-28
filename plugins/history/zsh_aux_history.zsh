0=${(%):-%N}
if (( ! ${+functions[gen-uuid7]} )); then
  source ${0:A:h:h}/helper/helper.plugin.zsh
fi

zmodload zsh/datetime 2>/dev/null
typeset -gA _zsh_aux_hist_state
if [[ -n "${_zsh_aux_hist_state[loaded]:-}" ]]; then
  return 0
fi
_zsh_aux_hist_state[loaded]=1

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

_zsh_aux_hist_json_insert() {
  emulate -L zsh
  setopt local_options
  jq -cn \
    --arg     sid        "$2" \
    --arg     cwd        "$3" \
    --arg     cmd        "$4" \
    --argjson ret        "$5" \
    --arg     pipestatus "$6" \
    --argjson start_ts   "$7" \
    --argjson end_ts     "$8" \
    '{sid:$sid,cwd:$cwd,cmd:$cmd,ret:$ret,pipestatus:$pipestatus,start_ts:$start_ts,end_ts:$end_ts}' \
    >> "$1"
}

_zsh_aux_hist_preexec() {
  local _ignore_space=$options[hist_ignore_space]
  local _reduce_blanks=$options[hist_reduce_blanks]
  emulate -L zsh
  setopt local_options extended_glob

  local cmd="$1"
  [[ -z "$cmd" ]] && return 0
  [[ "$_ignore_space" == on && "$cmd[1]" == ' ' ]] && return 0

  if [[ "$_reduce_blanks" == on ]]; then
    cmd="${${${cmd//[[:blank:]][[:blank:]]##/ }##[[:blank:]]##}%%[[:blank:]]##}"
  fi

  _zsh_aux_hist_state[cmd]="$cmd"
  _zsh_aux_hist_state[start_ts]="$EPOCHREALTIME"
}

_zsh_aux_hist_precmd() {
  local -a _ps=("${pipestatus[@]}")
  local _ignore_dups=$options[hist_ignore_dups]
  local _ignore_all_dups=$options[hist_ignore_all_dups]
  emulate -L zsh
  setopt local_options

  local my_pipestatus="${(j:,:)_ps}"
  local ret="${_ps[-1]}"
  [[ -z "${_zsh_aux_hist_state[cmd]:-}" ]] && return 0

  local end_ts start_ts cmd cwd sid f
  cmd="${_zsh_aux_hist_state[cmd]}"

  if [[ ( "$_ignore_dups" == on || "$_ignore_all_dups" == on ) \
        && "$cmd" == "${_zsh_aux_hist_state[last_cmd]:-}" ]]; then
    unset '_zsh_aux_hist_state[cmd]'
    unset '_zsh_aux_hist_state[start_ts]'
    return 0
  fi

  end_ts="$EPOCHREALTIME"
  start_ts="${_zsh_aux_hist_state[start_ts]:-0}"
  cwd="$PWD"
  sid="${_zsh_aux_hist_state[session]}"

  if zstyle -t ':zephyr:plugin:history:aux:sqlite' enable; then
    zstyle -s ':zephyr:plugin:history:aux:sqlite' histfile 'f' \
      || f="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history.db"
    if [[ "${_zsh_aux_hist_state[sqlite_init]}" != "$f" ]]; then
      _zsh_aux_hist_sqlite_init "$f" && _zsh_aux_hist_state[sqlite_init]="$f"
    fi
    [[ "${_zsh_aux_hist_state[sqlite_init]}" == "$f" ]] && \
      _zsh_aux_hist_sqlite_insert "$f" "$sid" "$cwd" "$cmd" "$ret" "$my_pipestatus" "$start_ts" "$end_ts" &|
  fi

  if zstyle -t ':zephyr:plugin:history:aux:json' enable; then
    zstyle -s ':zephyr:plugin:history:aux:json' histfile 'f' \
      || f="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history.json"
    if [[ "${_zsh_aux_hist_state[json_init]}" != "$f" ]]; then
      _zsh_aux_hist_json_init "$f" && _zsh_aux_hist_state[json_init]="$f"
    fi
    [[ "${_zsh_aux_hist_state[json_init]}" == "$f" ]] && \
      _zsh_aux_hist_json_insert "$f" "$sid" "$cwd" "$cmd" "$ret" "$my_pipestatus" "$start_ts" "$end_ts" &|
  fi

  _zsh_aux_hist_state[last_cmd]="$cmd"
  unset '_zsh_aux_hist_state[cmd]'
  unset '_zsh_aux_hist_state[start_ts]'
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _zsh_aux_hist_preexec
add-zsh-hook precmd _zsh_aux_hist_precmd

# Run first so pipestatus isn't clobbered by other precmd hooks.
precmd_functions=(_zsh_aux_hist_precmd ${precmd_functions:#_zsh_aux_hist_precmd})

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

_zsh_aux_hist_json_init() {
  emulate -L zsh
  setopt local_options
  local f="$1"
  mkdir -p "${f:h}" || return 1

  (( $+commands[jq] )) || {
    printf 'zsh_aux_history: jq required for json backend\n' >&2
    return 1
  }

  [[ -f "$f" ]] || touch "$f"
}

gen-uuid7 >/dev/null
_zsh_aux_hist_state[session]="$REPLY"
