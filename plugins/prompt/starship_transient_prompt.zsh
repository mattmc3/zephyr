# https://www.zsh.org/mla/users/2019/msg00633.html
# https://github.com/starship/starship/issues/888#issuecomment-580127661
function zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0
  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT

  local magenta bold off
  if command -v tput >/dev/null; then
    magenta="$(tput setaf 5)"
    bold="$(tput bold)"
    off="$(tput sgr0)"
  fi

  PROMPT="${magenta}${bold}%# ${off}"
  RPROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}
