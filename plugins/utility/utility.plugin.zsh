#
# utility: Misc Zsh shell options, utilities, and attempt at cross-platform conformity.
#

# References:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/utility/init.zsh
# - https://github.com/belak/zsh-utils/blob/main/utility/utility.plugin.zsh

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

if ! zstyle -t ':zephyr:plugin:utility:setopt' skip; then
  # 16.2.7 Job Control
  setopt auto_resume             # Attempt to resume existing job before creating a new process.
  setopt long_list_jobs          # List jobs in the long format by default.
  setopt notify                  # Report status of background jobs immediately.
  setopt NO_bg_nice              # Don't run all background jobs at a lower priority.
  setopt NO_check_jobs           # Don't report on jobs when shell exit.
  setopt NO_hup                  # Don't kill jobs on shell exit.
fi

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
alias help=run-help

# Ensure a python command exists.
if (( $+commands[python3] )) && ! (( $+commands[python] )); then
  alias python=python3
fi

# Ensure envsubst command exists.
if ! (( $+commands[envsubst] )); then
  alias envsubst="python -c 'import os,sys;[sys.stdout.write(os.path.expandvars(l)) for l in sys.stdin]'"
fi

# Ensure hex dump (hd) command exists.
if ! (( $+commands[hd] )) && (( $+commands[hexdump] )); then
  alias hd="hexdump -C"
fi

# Ensure open command exists.
if ! (( $+commands[open] )); then
  if [[ "$OSTYPE" == cygwin* ]]; then
    alias open='cygstart'
  elif [[ "$OSTYPE" == linux-android ]]; then
    alias open='termux-open'
  elif (( $+commands[xdg-open] )); then
    alias open='xdg-open'
  fi
fi

# Ensure pbcopy/pbpaste commands exist.
if ! (( $+commands[pbcopy] )); then
  if [[ "$OSTYPE" == cygwin* ]]; then
    alias pbcopy='tee > /dev/clipboard'
    alias pbpaste='cat /dev/clipboard'
  elif [[ "$OSTYPE" == linux-android ]]; then
    alias pbcopy='termux-clipboard-set'
    alias pbpaste='termux-clipboard-get'
  elif (( $+commands[wl-copy] && $+commands[wl-paste] )); then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif [[ -n $DISPLAY ]]; then
    if (( $+commands[xclip] )); then
      alias pbcopy='xclip -selection clipboard -in'
      alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
  fi
fi

if ! zstyle -t ':zephyr:plugin:utility:function' skip; then
  ##? Cross platform `sed -i` syntax
  function sedi {
    # GNU/BSD
    sed --version &>/dev/null && sed -i -- "$@" || sed -i "" "$@"
  }
fi

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:utility' loaded 'yes'
