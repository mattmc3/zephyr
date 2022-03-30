0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h}}

# this file should contain the bare minimum to bootstrap Zephyr so that plugins can
# remain independant

autoload -Uz $ZEPHYR_HOME/functions/autoload-dir
autoload-dir "$ZEPHYR_HOME/functions"

_zephyr_plugins_default=(
  environment
  terminal
  editor
  history
  directory
  utility
  magic-enter
  zfunctions
  confd
  completions
  autosuggestions
  prompt
  syntax-highlighting
  history-substring-search
)
zstyle -a ':zephyr:load' plugins \
  '_zephyr_plugins' || _zephyr_plugins=($_zephyr_plugins_default)

for _zephyr_plugin in $_zephyr_plugins; do
  source $ZEPHYR_HOME/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh
done
unset _zephyr_plugin{s,s_default,}
