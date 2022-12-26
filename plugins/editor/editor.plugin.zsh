###
# editor - Set editor specific key bindings, options, and variables.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%x}
: ${ZEPHYR_HOME:=${0:A:h:h:h}}
zstyle -t ':zephyr:core' initialized || . $ZEPHYR_HOME/lib/init.zsh

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
