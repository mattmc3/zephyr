#
# macos - Aliases and functions for macOS users.
#

#
# References
#

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
# https://github.com/sorin-ionescu/prezto/tree/master/modules/osx

#
# Requirements
#

[[ "$OSTYPE" == darwin* ]] || return 1

#
# Functions
#

# Load plugin functions.
0=${(%):-%N}
fpath=(${0:a:h}/functions $fpath)
autoload -Uz ${0:a:h}/functions/*(.:t)

#
# Wrap up
#

zstyle ":zephyr:plugin:macos" loaded 'yes'
