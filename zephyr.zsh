# Zephyr - Nice as a summer breeze.

# Bootstrap Zephyr.
0=${(%):-%N}
ZEPHYR_HOME=${0:a:h}
source $ZEPHYR_HOME/lib/bootstrap.zsh

# Every plugin Zephyr ships, in the order they load.
_zephyr_all_plugins=(
  environment
  homebrew
  color
  compstyle
  completion
  directory
  editor
  history
  history-search
  autosuggest
  prompt
  utility
  zfunctions
  macos
  confd
)

# These take over keys, so they are opt-in.
_zephyr_optout_plugins=(history-search autosuggest)

# Nothing for macos to do off a Mac. Other plugins check their own requirements.
[[ "$OSTYPE" == darwin* ]] || _zephyr_all_plugins=(${_zephyr_all_plugins:#macos})

# Name the plugins you want, in the order you want them:
#   zstyle ':zephyr:load' plugins zfunctions directory editor history
# Or take a ready-made list, 'default' or 'all':
#   zstyle ':zephyr:load' plugins-preset 'all'
if ! zstyle -a ':zephyr:load' plugins '_zephyr_plugins'; then
  zstyle -s ':zephyr:load' plugins-preset '_zephyr_preset' || _zephyr_preset=default
  _zephyr_plugins=(${_zephyr_all_plugins:|_zephyr_optout_plugins})
  case "$_zephyr_preset" in
    default) ;;
    all) _zephyr_plugins=($_zephyr_all_plugins) ;;
    *) print -ru2 -- "zephyr: Unknown plugins-preset '$_zephyr_preset'." ;;
  esac
fi

# A plugin from a tree Zephyr does not ship is named for where it comes from, and the
# tree is registered by a name of your choosing:
#   zstyle ':zephyr:load:contrib' omz ${ZDOTDIR:-$HOME/.zsh}/contrib/ohmyzsh
#   zstyle ':zephyr:load' plugins editor omz:git
# A bare name is always Zephyr's own, so nothing upstream can take one by existing.
_zephyr_core_dirs=(${ZSH_CUSTOM:-$__zsh_config_dir}/plugins $ZEPHYR_HOME/plugins)

for _zephyr_plugin in $_zephyr_plugins; do
  _zephyr_name=${_zephyr_plugin##*:}
  _zephyr_searched=($_zephyr_core_dirs)

  # Qualified: that tree and nowhere else. $ZSH_CUSTOM is for your own plugins.
  if [[ "$_zephyr_plugin" == *:* ]]; then
    if zstyle -s ':zephyr:load:contrib' "${_zephyr_plugin%%:*}" '_zephyr_dir'; then
      _zephyr_searched=("$_zephyr_dir/plugins")
    else
      zstyle -g _zephyr_known ':zephyr:load:contrib'
      print -ru2 -- "zephyr: Unknown contrib '${_zephyr_plugin%%:*}'. Registered: ${${(j:, :)_zephyr_known}:-none}"
      continue
    fi
  fi

  _initfiles=(${^_zephyr_searched}/${_zephyr_name}/${_zephyr_name}.plugin.zsh(N))
  if (( ! $#_initfiles )); then
    print -ru2 -- "zephyr: Plugin not found '$_zephyr_plugin'. Looked in: ${(j:, :)_zephyr_searched}"
  elif source "$_initfiles[1]"; then
    zstyle ":zephyr:plugin:$_zephyr_name" loaded 'yes'
  else
    zstyle ":zephyr:plugin:$_zephyr_name" loaded 'no'
  fi
done

# Clean up.
unset _zephyr_plugin{s,} _zephyr_{all,optout}_plugins _zephyr_core_dirs _zephyr_preset _initfiles
unset _zephyr_{name,dir,known,searched}
