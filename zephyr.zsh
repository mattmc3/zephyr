# this file should contain the bare minimum to bootstrap Zephyr so that plugins can
# remain independent

0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h}}
source $ZEPHYR_HOME/lib/init.zsh

# load plugins
_zephyr_plugins_default=(
  colors
  environment
  editor
  history
  directory
  utility
  prompt
  $ZEPHYR_HOME/.external
)
zstyle -a ':zephyr:load' plugins \
  '_zephyr_plugins' || _zephyr_plugins=($_zephyr_plugins_default)

for _zephyr_plugin in $_zephyr_plugins; do
  source $ZEPHYR_HOME/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh
done
unset _zephyr_plugin{s,s_default,}
