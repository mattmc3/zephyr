#!/bin/zsh
##? substenv - substitutes string parts with environment variables
function substenv {
  if (( $# == 0 )); then
    subenv ZDOTDIR | subenv HOME
  else
    local sedexp="s|${(P)1}|\$$1|g"
    shift
    sed "$sedexp" "$@"
  fi
}

function collect-input {
  local -a input=()
  if (( $# > 0 )); then
    input=("${(s.\n.)${@}}")
  elif [[ ! -t 0 ]]; then
    local data
    while IFS= read -r data || [[ -n "$data" ]]; do
      input+=("$data")
    done
  fi
  printf '%s\n' "${input[@]}"
}

function string-escape {
  local -a input=("${(@f)$(collect-input "$@")}")
  print -lr ${(qqqq)input[@]} | sed -e 's/\\033/\\e\\/g' -e 's/ /\\ /g' | tr -d "$'"
}
