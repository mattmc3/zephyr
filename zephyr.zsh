# this file should contain the bare minimum to bootstrap Zephyr so that plugins can
# remain independent

0=${(%):-%x}
ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h}}

fpath=($ZEPHYR_HOME/functions $fpath)
autoload -U $fpath[1]/*(.:t)

# allow overriding plugins
_zhome=${ZDOTDIR:-${XDG_CONFIG_HOME:=$HOME/.config}/zsh}
ZSH_CUSTOM="${ZSH_CUSTOM:-$_zhome}"

# load zstyles from .zstyles if file found
[[ -f ${ZDOTDIR:-$HOME}/.zstyles ]] && . ${ZDOTDIR:-$HOME}/.zstyles

# get list of plugins from zstyle or plugins variable
zstyle -a ':zephyr:load' plugins \
  '_zephyr_plugins' || _zephyr_plugins=($plugins)

# if nothing provided, use the default list
(( $#_zephyr_plugins )) ||
  _zephyr_plugins=(
    color
    environment
    editor
    history
    directory
    utility
    prompt
    completion
  )

# Load plugins.
for _zephyr_plugin in $_zephyr_plugins; do
  _initfiles=(
    $ZSH_CUSTOM/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh(N)
    $ZEPHYR_HOME/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh(N)
  )
  if (( $#_initfiles )); then
    # echo "Loading plugin $_zephyr_plugin from $_initfiles[1]"
    source "$_initfiles[1]"
    if [[ $? -eq 0 ]]; then
      zstyle ":zephyr:plugin:$_zephyr_plugin" loaded 'yes'
    else
      zstyle ":zephyr:plugin:$_zephyr_plugin" loaded 'no'
    fi
  else
    echo >&2 "zephyr: Plugin not found '$_zephyr_plugin'."
  fi
done

# Update weekly (quietly).
zephyr-updatecheck &>/dev/null

# tell plugins that Zephyr has been initialized
zstyle ':zephyr:core' initialized 'yes'

# cleanup
unset _zhome _zephyr_plugin{s,} _initfiles
