###
# .zshrc - Execute commands at the start of an interactive session.
###

# Source Zephyr.
ZEPHYR_HOME=${ZDOTDIR:-$HOME}/.zephyr
if [[ ! -d "$ZEPHYR_HOME" ]]; then
  git clone --recursive git@github.com:mattmc3/zephyr "$ZEPHYR_HOME"
fi
source $ZEPHYR_HOME/zepyhr.zsh

# Customize to your needs...
