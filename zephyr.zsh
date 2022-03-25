0=${(%):-%x}

#
# Cache
#

if (( $+commands[brew] )); then
  # 'brew --prefix' is slow; cache its output
  brew_prefix_file="${0:a:h}/.cache/brew_prefix.zsh"
  if [[ ! -e "$brew_prefix_file" ]]; then
    mkdir -p "$brew_prefix_file:h"
    echo "zstyle ':zephyr:brew:prefix' 'path' $(brew --prefix 2>/dev/null)" >! "$brew_prefix_file"
  fi
  source "$brew_prefix_file"
  unset brew_prefix_file
fi

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
