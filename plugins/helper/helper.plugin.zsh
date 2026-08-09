#region HEADER
#
# helper: Common variables and functions used by Zephyr plugins.
#
#endregion

# Make a directory from a variable name.
function mkdirvar {
  emulate -L zsh
  local zdirvar
  for zdirvar in $@; do
    [[ -d "${(P)zdirvar}" ]] || mkdir -p "$(P){zdirvar}"
  done
}

# Cache the results of an eval command
function cached-eval {
  local sourcefile=''

  # Refresh under our options, source under yours, so a cached file can setopt.
  () {
    emulate -L zsh
    setopt local_options extended_glob

    : ${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}
    local cachedir=$__zsh_cache_dir/cached-eval

    local -i clear=0
    [[ "$1" == --clear ]] && { clear=1; shift }

    if (( clear && ! $# )); then
      command rm -f $cachedir/*(N.)
      return
    fi
    (( $# )) || return 1

    # Hash the whole command line, so different args get different caches.
    local c
    local -i hash=5381
    for c in ${(s::)${(j: :)@}}; do
      (( hash = (hash * 33 + #c) % 4294967296 ))
    done
    local cachefile=$cachedir/${1:t}-${hash}.zsh

    if (( clear )); then
      command rm -f $cachefile
      return
    fi

    # Rebuild via a temp file so a failed command doesn't poison the cache.
    if [[ -z $cachefile(#qNmh-20) ]]; then
      mkdir -p $cachefile:h
      if ! "$@" >| $cachefile.$$; then
        command rm -f $cachefile.$$
        return 1
      fi
      command mv -f $cachefile.$$ $cachefile
    fi

    sourcefile=$cachefile
  } "$@" || return 1

  [[ -n "$sourcefile" ]] || return 0  # --clear leaves nothing to source
  source $sourcefile
}

# Check if a file can be autoloaded by trying to load it in a subshell.
function is-autoloadable {
  ( unfunction "$1"; autoload -U +X "$1" ) &> /dev/null
}

# Check if a name is a command, function, or alias.
function is-callable {
  (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
}

# Check whether a string represents "true" (1, y, yes, t, true, o, on).
function is-true {
  [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|o(n|)) ]]
}

# OS checks.
function is-macos  { [[ "$OSTYPE" == darwin* ]] }
function is-linux  { [[ "$OSTYPE" == linux*  ]] }
function is-bsd    { [[ "$OSTYPE" == *bsd*   ]] }
function is-cygwin { [[ "$OSTYPE" == cygwin* ]] }
function is-termux { [[ "$OSTYPE" == linux-android ]] }

# Check term family.
function is-term-family {
  [[ $TERM = $1 || $TERM = $1-* ]]
}

# Check if tmux.
function is-tmux {
  is-term-family tmux || [[ -n "$TMUX" ]]
}

# Generate a UUID v7 (time-ordered). Result is stored in REPLY.
function gen-uuid7 {
  emulate -L zsh
  zmodload zsh/datetime 2>/dev/null

  local uuid7
  local now sec frac ms ts_hex rand_hex
  local g1 g2 g3 g4 g5

  now="$EPOCHREALTIME"
  sec="${now%%.*}"
  frac="${now#*.}"
  [[ "$frac" == "$now" ]] && frac=0
  frac="${frac}000000"
  ms=$(( 10#${sec} * 1000 + 10#${frac[1,3]} ))
  ts_hex="$(printf '%012x' "$ms")"

  rand_hex=$(od -An -N10 -tx1 /dev/urandom | tr -d ' \n')

  g1="${ts_hex[1,8]}"
  g2="${ts_hex[9,12]}"
  g3="7${rand_hex[1,3]}"
  g4="$(printf '%x' $(( (16#${rand_hex[4]} & 3) | 8 )))${rand_hex[5,7]}"
  g5="${rand_hex[8,19]}"

  typeset -g REPLY="${g1}-${g2}-${g3}-${g4}-${g5}"
  print -- "$REPLY"
}

#region MARK LOADED
zstyle ':zephyr:plugin:helper' loaded 'yes'
#endregion
