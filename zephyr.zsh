0=${(%):-%x}

#
# Functions
#

function _zephyr_autoload_funcdir {
  [[ -d "$1" ]] || return 1
  fpath+="$1"
  local fn
  for fn in "$1"/*(.N); do
    autoload -Uz $fn
  done
}

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
  source ${0:a:h}/plugins/$_zephyr_plugin/$_zephyr_plugin.plugin.zsh
done

#
# Clean up
#

unset _zephyr_plugin{s,s_default,}
unfunction _zephyr_autoload_funcdir
