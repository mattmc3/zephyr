#
# Defines general aliases and functions.
#

#region: Init
0=${(%):-%x}
zstyle -t ':zephyr:core' initialized || source ${0:A:h:h:h}/lib/init.zsh
#endregion

#region: Functions
autoload-dir "${0:A:h}/functions"

function -coreutils-alias-setup {
  # Prefix will either be g or empty. This is to account for GNU Coreutils being
  # installed alongside BSD Coreutils
  local prefix=$1

  # set LS_COLORS
  eval "$(${prefix}dircolors --sh)"

  alias ${prefix}ls="${aliases[${prefix}ls]:-${prefix}ls} --group-directories-first --color=auto"
}
#endregion

#region: External
export PATH="$ZEPHYR_HOME/.external/romkatv/zsh-bench:$PATH"
#endregion

#region: Aliases
alias type="type -a"
alias mkdir="mkdir -p"

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
GREP_EXCL=(.bzr CVS .git .hg .svn .idea .tox)

# macOS utils everywhere
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
  alias grep="${aliases[grep]:-grep} --exclude-dir={\${(j.,.)GREP_EXCL}}"
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

#region: Extended tools
# OS-specific tools
if [[ "$OSTYPE" == darwin* ]]; then
  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
  # https://github.com/sorin-ionescu/prezto/tree/master/modules/osx
  autoload-dir "${0:A:h}/functions-macos"

  # homebrew
  if (( $+commands[brew] )); then
    autoload-dir "${0:A:h}/functions-macos/homebrew"
  fi

  # Dash.app
  autoload-dir "${0:A:h}/functions-macos/dash"

  # aliases
  alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

  # flush DNS
  alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

  # finder integrations
  alias ofd='open "$PWD"'

  # changes directory to the current Finder directory
  alias cdf='cd "$(pfd)"'

  # pushes directory to the current Finder directory
  alias pushdf='pushd "$(pfd)"'

  # canonical hex dump; some systems have this symlinked
  command -v hd > /dev/null || alias hd="hexdump -C"

  # MacOS has no 'md5sum', so use 'md5' as a fallback
  command -v md5sum > /dev/null || alias md5sum="md5"

  # MacOS has no 'sha1sum', so use 'shasum' as a fallback
  command -v sha1sum > /dev/null || alias sha1sum="shasum"
fi
#endregion

#region: Cleanup
unfunction -- -coreutils-alias-setup
#endregion
