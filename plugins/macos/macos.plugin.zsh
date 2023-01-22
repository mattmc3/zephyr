###
# macos - Aliases and functions for macOS users.
#
# References:
# - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/osx
###

#
# Requirements
#

[[ "$OSTYPE" == darwin* ]] || return 1

#
# Init
#

fpath=(${0:A:h}/functions ${0:A:h}/completions $fpath)
autoload -U $fpath[1]/*(.:t)
