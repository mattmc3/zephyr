###
# utility - Common shell utilities, many aimed at making cross platform work less painful.
###

#
# Requirements
#

setopt EXTENDED_GLOB

_cache_dir=${XDG_CACHE_HOME:=$HOME/.cache}/zephyr
[[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"

#
# Aliases
#

# General aliases
alias type="type -a"
alias mkdir="mkdir -p"

function -coreutils-alias-setup {
  # Prefix will either be g or empty. This is to account for GNU Coreutils being
  # installed alongside BSD Coreutils
  local prefix=$1

  # Cache results of running dircolors for 20 hours, so it should almost
  # always regenerate the first time a shell is opened each day.
  local dircolors_cache=$_cache_dir/${prefix}dircolors.zsh
  local cache_files=($dircolors_cache(Nmh-20))
  if ! (( $#cache_files )); then
    ${prefix}dircolors --sh >| $dircolors_cache
  fi
  source "${dircolors_cache}"

  alias ${prefix}ls="${aliases[${prefix}ls]:-${prefix}ls} --group-directories-first --color=auto"
}

# dircolors is a surprisingly good way to detect GNU vs BSD coreutils
if (( $+commands[gdircolors] )); then
  -coreutils-alias-setup g
fi

if (( $+commands[dircolors] )); then
  -coreutils-alias-setup
else
  alias ls="${aliases[ls]:-ls} -G"
fi

alias grep="${aliases[grep]:-grep} --color=auto"

# macOS utils everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
elif [[ "$OSTYPE" == cygwin* ]]; then
  alias o='cygstart'
  alias pbcopy='tee > /dev/clipboard'
  alias pbpaste='cat /dev/clipboard'
elif [[ "$OSTYPE" == linux-android ]]; then
  alias o='termux-open'
  alias pbcopy='termux-clipboard-set'
  alias pbpaste='termux-clipboard-get'
else
  alias o='xdg-open'

  if [[ -n $DISPLAY ]]; then
    if (( $+commands[xclip] )); then
      alias pbcopy='xclip -selection clipboard -in'
      alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
  else
    if (( $+commands[wl-copy] && $+commands[wl-paste] )); then
      alias pbcopy='wl-copy'
      alias pbpaste='wl-paste'
    fi
  fi
fi

alias pbc='pbcopy'
alias pbp='pbpaste'

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
alias help=run-help

#
# Init
#

# Wrap zsh-defer.
if (( ! $+functions[zsh-defer] )); then
  function zsh-defer {
    0=${(%):-%x}
    source ${0:a:h}/external/zsh-defer/zsh-defer.plugin.zsh || return 1
    zsh-defer "$@"
  }
fi

# Use zsh-bench.
export PATH="${0:a:h}/external/zsh-bench:$PATH"

# Use zman.
source ${0:a:h}/external/zman/zman.zsh

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

#
# Cleanup
#

unfunction -- -coreutils-alias-setup
unset _cache_dir
