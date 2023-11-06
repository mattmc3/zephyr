#!/usr/bin/env zsh

##? string-length - print string lengths
##? usage: string length [STRING...]
function string-length {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- $#s
  done
}

##? string-lower - convert strings to lowercase
##? usage: string lower [STRING...]
function string-lower {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:l}
  done
}

##? string-upper - convert strings to uppercase
##? usage: string upper [STRING...]
function string-upper {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:u}
  done
}

##? string-trim - remove leading and trailing whitespace
##? usage: string trim [STRING...]
function string-trim {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  printf '%s\n' "$@" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

##? string-escape - escape special characters
##? usage: string escape [STRING...]
function string-escape {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:q}
  done
}

##? string-unescape - expand escape sequences
##? usage: string unescape [STRING...]
function string-unescape {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:Q}
  done
}

##? string-join - join strings with delimiter
##? usage: string join SEP [STRING...]
function string-join {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local sep=$1; shift
  print -r -- ${(pj.$sep.)@}
}

##? string-join0 - join strings with null character
##? usage: string join0 [STRING...]
function string-join0 {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  string-join $'\0' "$@" ''
}

##? string-split - split strings by delimiter
##? usage: string split SEP [STRING...]
function string-split {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  printf '%s\n' "${(@ps.$1.)@[2,-1]}"
}

##? string-split0 - split strings by null character
##? usage: string split0 [STRING...]
function string-split0 {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  set -- "${@%$'\0'}"
  string-split $'\0' "$@"
}

##? string-sub - extract substrings
##? usage: string sub [-s start] [-e end] [STRINGS...]
function string-sub {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local -A opts=(-s 1 -e '-1')
  zparseopts -D -F -K -A opts -- s: e: || return 1
  local s
  for s in "$@"; do
    print -r -- $s[$opts[-s],$opts[-e]]
  done
}

##? string-sub0 - extract substrings using 0-based indexing
##? usage: string sub0 [-o offset] [-l len] [STRINGS...]
function string-sub0 {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local -A opts=(-o 0)
  zparseopts -D -K -A opts -- o: l:
  local s
  for s in "$@"; do
    print -r -- ${s:$opts[-o]:${opts[-l]:-$#s}}
  done
}

##? string-pad - pad strings to a fixed width
##? usage: string pad [-r] [-c padchar] [-w width] [STRINGS...]
function string-pad {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s rl padexp
  local -A opts=(-c ' ' -w 0)
  zparseopts -D -K -F -A opts -- r c: w: || return 1
  for s in "$@"; do
    [[ $#s -gt $opts[-w] ]] && opts[-w]=$#s
  done
  for s in "$@"; do
    [[ -v opts[-r] ]] && rl='r' || rl='l'
    padexp="$rl:$opts[-w]::$opts[-c]:"
    eval "print -r -- \"\${($padexp)s}\""
  done
}

##? string-shorten - shorten strings to a max width, with an ellipsis
##? usage: string shorten [-c] [-m max] [STRINGS...]
function string-shorten {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local -A opts=(-c …)
  zparseopts -D -K -A opts -- c: m:
  # user provided max len, or take the shortest string length
  local s len=$#1
  if [[ -v opts[-m] ]]; then
    len=$opts[-m]
  else
    for s in "$@"; [[ $#s -lt $len ]] && len=$#s
  fi
  for s in "$@"; do
    if [[ $#s -gt $len ]]; then
      print -r -- ${s:0:((len-$#opts[-c]))}${opts[-c]}
    else
      print -r -- $s
    fi
  done
}

##? string-repeat - multiply a string
##? usage: string repeat [-n count] [-m max] [-N][STRING ...]
function string-repeat {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s n
  local -A opts
  zparseopts -D -A opts -- n: m: N
  n=${opts[-n]:-$opts[-m]}
  for s in "$@"; do
    s=$(printf "$s%.0s" {1..$n})
    [[ -v opts[-m] ]] && printf "${s:0:$opts[-m]}" || printf "$s"
    [[ -v opts[-N] ]] || printf '\n'
  done
}

##? string - manipulate strings
function string {
  emulate -L zsh; setopt local_options
  0=${(%):-%x}

  if [[ "$1" == (-h|--help) ]]; then
    grep "^##? string -" ${0:A} | cut -c 5-
    echo "usage:"
    grep "^##? usage:" ${0:A} | cut -c 11- | sort
    return
  fi

  if [[ ! -t 0 ]] && [[ -p /dev/stdin ]]; then
    if (( $# )); then
      set -- "$@" "${(@f)$(cat)}"
    else
      set -- "${(@f)$(cat)}"
    fi
  fi

  if (( $+functions[string-$1] )); then
    string-$1 "$@[2,-1]"
  else
    echo >&2 "string: Subcommand '$1' is not valid." && return 1
  fi
}
