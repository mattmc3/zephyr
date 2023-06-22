#!/bin/zsh
#
# .zshrc - Execute commands at the start of an interactive session.
#

# Source Zephyr.
ZEPHYR_HOME=${ZDOTDIR:-$HOME}/.zephyr
[[ -d "$ZEPHYR_HOME" ]] ||
  git clone --recursive https://github.com/mattmc3/zephyr "$ZEPHYR_HOME"
source $ZEPHYR_HOME/zepyhr.zsh

# Customize to your needs...
