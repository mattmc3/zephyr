#
# Requirements
#

0=${(%):-%x}
if ! (( $+functions[zephyrinit] )); then
  autoload -Uz ${0:A:h:h:h}/functions/zephyrinit && zephyrinit
fi

#
# Init
#

fpath+=${0:A:h}/functions
autoload -Uz ${0:A:h}/functions/bindkey-all
source $ZEPHYR_HOME/.external/zsh-utils/editor/editor.plugin.zsh

#
# Options
#

setopt NO_BEEP   # Do not beep on error in line editor.
