# Zephyr - Nice as a summer breeze.

# Bootstrap Zephyr.
0=${(%):-%N}
source ${0:a:h}/lib/bootstrap.zsh

# Load plugins.
zstyle -a ':zephyr:load' plugins '_zephyr_plugins'
for _zephyr_plugin in $_zephyr_plugins; do
  # Allow overriding plugins.
  _initfiles=(
    ${ZSH_CUSTOM:-$__zsh_config_dir}/plugins/${_zephyr_plugin}/${_zephyr_plugin}.plugin.zsh(N)
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

# Clean up.
unset _zephyr_plugin{s,} _initfiles
