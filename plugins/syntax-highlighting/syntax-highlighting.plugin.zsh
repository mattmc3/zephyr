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

source $ZEPHYR_HOME/.external/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
