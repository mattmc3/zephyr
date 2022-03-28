# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
# https://github.com/sorin-ionescu/prezto/tree/master/modules/osx

#region: Functions

0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h:h:h}}
(( $+functions[autoload-dir] )) || autoload -Uz $ZEPHYR_HOME/functions/autoload-dir
autoload-dir "${0:A:h}/functions"

#endregion

#region: Aliases

alias lmk="say 'Process complete.'"
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

# macOS has no 'md5sum', so use 'md5' as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no 'sha1sum', so use 'shasum' as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

#endregion
