#region: Functions

0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h:h:h}}
(( $+functions[autoload-dir] )) || autoload -Uz $ZEPHYR_HOME/functions/autoload-dir
autoload-dir "${0:A:h}/functions"

#endregion

#region: External

if [[ ! -d "${0:A:h}/external/zsh-bench" ]]; then
  command git clone --quiet --depth 1 \
    https://github.com/romkatv/zsh-bench \
    "${0:A:h}/external/zsh-bench"
fi
export PATH="${0:A:h}/external/zsh-bench:$PATH"

# endregion

#region: Aliases

alias type="type -a"
alias mkdir="mkdir -p"

function -coreutils-alias-setup {
  # Prefix will either be g or empty. This is to account for GNU Coreutils being
  # installed alongside BSD Coreutils
  local prefix=$1

  # set LS_COLORS
  eval "$(${prefix}dircolors --sh)"

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
GREP_EXCLUDEDIRS=${GREP_EXCLUDEDIRS:-'{.bzr,CVS,.git,.hg,.svn,.idea,.tox}'}

# macOS utils everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
  alias grep='grep --color=auto --exclude-dir=$GREP_EXCLUDEDIRS'
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

#endregion

#region: Help

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help

#endregion

#region: Cleanup

unfunction -- -coreutils-alias-setup

#endregion
