###
# editor - Set editor specific key bindings, options, and variables.
###

#
# Requirements
#

zstyle -t ':zephyr:core' initialized || return 1
[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

fpath+=${0:A:h}/functions
autoload -Uz ${0:A:h}/functions/bindkey-all
source $ZEPHYR_HOME/.external/zsh-utils/editor/editor.plugin.zsh

#
# Options
#

# Unset bad options from zsh-utils
unsetopt BEEP   # Do not beep on error in line editor.
