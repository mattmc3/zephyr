# The json backend: one JSON object per line, appended.
#
#   zstyle ':zephyr:plugin:history:aux:json' enable yes

_zsh_aux_hist_backends+=(json)
_zsh_aux_hist_defaults[json]="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/zsh_history.json"

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
