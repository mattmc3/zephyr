#
# Requirements
#

0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-$0:A:h:h:h}
[[ -e $ZEPHYR_HOME/.external/zsh-utils ]] ||
  git clone --depth 1 --quiet https://github.com/belak/zsh-utils $ZEPHYR_HOME/.external/zsh-utils

#
# Init
#

source $ZEPHYR_HOME/.external/zsh-utils/history/history.plugin.zsh
