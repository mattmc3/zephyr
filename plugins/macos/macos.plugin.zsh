#
# macos: Aliases and functions for macOS users.
#

# References
# - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/osx

# Expecting macOS.
[[ "$OSTYPE" == darwin* ]] || return 1

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:plugin:helper' loaded || source ${0:a:h:h}/helper/helper.plugin.zsh

# Load plugin functions.
0=${(%):-%N}
fpath=(${0:a:h}/functions $fpath)
autoload -Uz ${0:a:h}/functions/*(.:t)

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:macos' loaded 'yes'
