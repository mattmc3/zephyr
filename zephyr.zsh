0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h}}

# this file should contain the bare minimum to bootstrap Zephyr so that plugins can
# remain independant

fpath+=($ZEPHYR_HOME/functions)
autoload -Uz zephyrinit && zephyrinit

_zephyr_plugins_default=(
  colors
  environment
  editor
  history
  directory
  utility
  prompt
  completions
)
zstyle -a ':zephyr:load' plugins \
  '_zephyr_plugins' || _zephyr_plugins=($_zephyr_plugins_default)

for _zephyr_plugin in $_zephyr_plugins; do
  source $ZEPHYR_HOME/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh
done
unset _zephyr_plugin{s,s_default,}
