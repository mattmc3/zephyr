# This file should contain the bare minimum to bootstrap Zephyr so that plugins can
# remain independent.

# Initialize Zephyr.
0=${(%):-%x}
source ${0:A:h}/plugins/zephyr/zephyr.plugin.zsh

# Determine plugin locations.
_zhome=${ZDOTDIR:-${XDG_CONFIG_HOME:=$HOME/.config}/zsh}
_zcust="${ZSH_CUSTOM:-$_zhome}"

# Load plugins.
zstyle -a ':zephyr:load' plugins '_zephyr_plugins'
for _zephyr_plugin in $_zephyr_plugins; do
  # Allow overriding plugins.
  _initfiles=(
    $_zcust/plugins/${_zephyr_plugin}/${_zephyr_plugin}.plugin.zsh(N)
    $ZEPHYR_HOME/plugins/${_zephyr_plugin}/${_zephyr_plugin}.plugin.zsh(N)
  )
  if (( $#_initfiles )); then
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

# cleanup
unset _z{home,cust} _zephyr_plugin{s,} _initfiles
