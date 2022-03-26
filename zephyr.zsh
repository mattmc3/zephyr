0=${(%):-%x}

#
# Plugin list
#

_zephyr_plugins_default=(
  environment
  terminal
  editor
  history
  directory
  utility
  prompt
  zfunctions
  confd
  completions
)
zstyle -a ':zephyr:load' plugins \
  '_zephyr_plugins' || _zephyr_plugins=($_zephyr_plugins_default)
for _zephyr_plugin in $_zephyr_plugins; do
  source ${0:A:h}/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh
done

#
# Clean up
#

unset _zephyr_plugin{s,s_default,}
