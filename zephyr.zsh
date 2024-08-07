# Zephyr - Nice as a summer breeze.

# Bootstrap Zephyr.
0=${(%):-%N}
ZEPHYR_HOME=${0:a:h}
source $ZEPHYR_HOME/lib/bootstrap.zsh

# Set which plugins to load. It doesn't really matter if we include plugins we don't
# need (eg: running Linux, not macOS) because the plugins themselves check and exit
# if requirements aren't met.
zstyle -a ':zephyr:load' plugins '_zephyr_plugins' ||
  _zephyr_plugins=(
    environment
    homebrew
    color
    compstyle
    completion
    directory
    editor
    helper
    history
    prompt
    utility
    zfunctions
    macos
    confd
  )

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
