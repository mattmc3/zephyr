###
# macos - Aliases and functions for macOS users.
###

#
# Requirements
#

[[ "$OSTYPE" == darwin* ]] || return 1

#
# Functions
#

function brew-desc {
  brew leaves | xargs brew desc --eval-all
}

function brew-ls {
  echo "==> Root Formulae"
  brew deps --installed --formula | \
      awk -F'[: ]+' \
      '{
          packages[$1]++
          for (i = 2; i <= NF; i++)
              dependencies[$i]++
      }
      END {
          for (package in packages)
              if (!(package in dependencies))
                  print package
      }' | \
      sort | column
  echo "\n==> Casks"
  brew list --cask
}

function mand {
  local -a o_docset=(manpages)
  zmodload zsh/zutil
  zparseopts -D -F -K -- \
    {d,-docset}:=o_docset ||
    return 1

  dashcmd="dash://${o_docset[-1]}%3A$1"
  open -a Dash.app $dashcmd 2> /dev/null
  if test $? -ne 0; then
    echo >&2 "$0: Dash is not installed"
    return 2
  fi
}

function manp {
  # https://scriptingosx.com/2022/11/on-viewing-man-pages-ventura-update/
  if ! (( $# )); then
    echo >&2 'manp: You must specify the manual page you want'
    return 1
  fi
  mandoc -T pdf "$(/usr/bin/man -w $@)" | open -fa Preview
}
compdef _man manp

function pfd {
  osascript 2> /dev/null <<EOF
    tell application "Finder"
      return POSIX path of (target of first window as text)
    end tell
EOF
}

function pfs {
  osascript 2>&1 <<EOF
    tell application "Finder" to set the_selection to selection
    if the_selection is not {}
      repeat with an_item in the_selection
        log POSIX path of (an_item as text)
      end repeat
    end if
EOF
}

# Remove .DS_Store files recursively in a directory, default .
function rmdsstore {
  find "${@:-.}" -type f -name .DS_Store -delete
}

function quick-look {
  (( $# > 0 )) && qlmanage -p $* &>/dev/null &
}

#
# Aliases
#

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
# https://github.com/sorin-ionescu/prezto/tree/master/modules/osx

alias lmk="say 'Process complete.'"
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# flush DNS
alias flushdns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

# open the current directory in a Finder window
alias ofd='open "$PWD"'

# changes directory to the current Finder directory
alias cdf='cd "$(pfd)"'

# pushes directory to the current Finder directory
alias pushdf='pushd "$(pfd)"'

# canonical hex dump; some systems have this symlinked
(( $+commands[hd] )) || alias hd="hexdump -C"

# macOS has no 'md5sum', so use 'md5' as a fallback
(( $+commands[md5sum] )) || alias md5sum="md5"

# macOS has no 'sha1sum', so use 'shasum' as a fallback
(( $+commands[sha1sum] )) || alias sha1sum="shasum"

#
# Init
#

fpath=(${0:A:h}/functions $fpath)
autoload -U $fpath[1]/*(.:t)
