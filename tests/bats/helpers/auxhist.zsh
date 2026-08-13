# Helpers for the aux history tests, sourced by the zsh side of a test body.
#
# The hooks hand their writes to background jobs, so a test waits for the write
# to land rather than guessing how long it takes. aux_wait polls, pausing on
# zselect the way the zle harness does.

zmodload zsh/datetime 2>/dev/null
zmodload zsh/zselect 2>/dev/null

# aux_wait <seconds> <command...> - true once the command succeeds.
function aux_wait {
  local -F deadline=$(( EPOCHREALTIME + $1 ))
  shift
  while (( EPOCHREALTIME < deadline )); do
    "$@" && return 0
    zselect -t 5 2>/dev/null || :
  done
  return 1
}

function aux_db { print -r -- "${XDG_DATA_HOME}/zsh/zsh_history.db" }
function aux_jsonl { print -r -- "${XDG_DATA_HOME}/zsh/zsh_history.json" }

# aux_sql <sql> - one query against the sqlite history, tab separated.
function aux_sql {
  sqlite3 -list -separator $'\t' "$(aux_db)" "$1" 2>/dev/null
}

# aux_rows <n> - true when the history holds exactly n rows.
function aux_rows { [[ "$(aux_sql 'SELECT count(*) FROM zsh_history;')" == "$1" ]] }

# aux_finished <n> - true when n rows carry an outcome. Waiting on this rather
# than on a row count is what keeps a half-written command out of an assertion.
function aux_finished {
  [[ "$(aux_sql 'SELECT count(*) FROM zsh_history WHERE end_ts IS NOT NULL;')" == "$1" ]]
}

# aux_lines <n> - true when the jsonl history holds exactly n lines.
function aux_lines {
  local f="$(aux_jsonl)"
  [[ -f "$f" ]] && (( $(wc -l < "$f") == $1 ))
}

# aux_run <cmd> [ret] - one command through the hooks, start to finish.
function aux_run {
  _zsh_aux_hist_preexec "$1"
  ( exit ${2:-0} )
  _zsh_aux_hist_precmd
}

# aux_pending - what preexec left for precmd to finish, empty when it passed.
function aux_pending { print -r -- "${_zsh_aux_hist_state[cmd]:-none}" }
