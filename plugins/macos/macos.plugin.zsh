###
# macos - Aliases and functions for macOS users.
###

#
# Requirements
#

[[ "$OSTYPE" == darwin* ]] || return 1

#
# Aliases
#

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
# https://github.com/sorin-ionescu/prezto/tree/master/modules/osx

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
