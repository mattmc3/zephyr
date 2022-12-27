# this file should contain the bare minimum to bootstrap Zephyr so that plugins can
# remain independent

0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h}}
source $ZEPHYR_HOME/lib/init.zsh

# allow OMZ plugins
ZSH=$ZEPHYR_HOME/.external/ohmyzsh
ZSH_CUSTOM="${ZSH_CUSTOM:-${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}"

# get list of plugins from zstyle or plugins variable
zstyle -a ':zephyr:load' plugins \
  '_zephyr_plugins' || _zephyr_plugins=($plugins)

# if nothing provided, use the default list
(( $#_zephyr_plugins )) ||
  _zephyr_plugins=(
    colors
    environment
    editor
    history
    directory
    utility
    prompt
    completions
  )

# Load plugins.
for _zephyr_plugin in $_zephyr_plugins; do
  _initfiles=(
    $ZSH_CUSTOM/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh(N)
    $ZEPHYR_HOME/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh(N)
    $ZSH/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh(N)
  )
  if (( $#_initfiles )); then
    echo "Loading plugin $_zephyr_plugin from $_initfiles[1]"
    source "$_initfiles[1]"
  else
    echo >&2 "zephyr: Plugin not found '$_zephyr_plugin'."
  fi
done
unset _zephyr_plugin{s,} _initfiles
