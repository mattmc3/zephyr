#!/bin/zsh

# zman - lookup Zsh documentation
if ! command -v fzf >/dev/null; then
  echo "fzf command not found" >&2
  return 1
fi

ZMAN_URL=${ZMAN_URL:-https://zsh.sourceforge.io/Doc/Release}
if [[ -z "$ZMAN_BROWSER" ]]; then
  if [[ -n "$BROWSER" ]]; then
    ZMAN_BROWSER=$BROWSER
  elif [[ "$OSTYPE" == darwin* ]]; then
    ZMAN_BROWSER=open
  elif [[ "$OSTYPE" == cygwin* ]]; then
    ZMAN_BROWSER=cygstart
  else
    ZMAN_BROWSER=xdg-open
  fi
fi

local basedir="${${(%):-%x}:a:h:h}"
if [[ -z "$zman_lookup" ]] || [[ ${(t)zman_lookup} != "association" ]]; then
  source $basedir/lib/zman_lookup.zsh
fi

query="$@"
local selection=$(printf "%s\n" "${(ko)zman_lookup[@]}" | fzf --layout=reverse-list --query=$query)
if [[ $? -eq 0 ]] && [[ -n "$selection" ]]; then
  $ZMAN_BROWSER $ZMAN_URL/${zman_lookup[$selection]}
fi
