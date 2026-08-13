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
  case "$_zephyr_preset" in
    all) _zephyr_plugins=($_zephyr_all_plugins) ;;
    default) _zephyr_plugins=(${_zephyr_all_plugins:|_zephyr_optout_plugins}) ;;
    *)
      echo >&2 "zephyr: Unknown plugins-preset '$_zephyr_preset'."
      _zephyr_plugins=(${_zephyr_all_plugins:|_zephyr_optout_plugins})
      ;;
  esac
fi

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
unset _zephyr_plugin{s,} _zephyr_{all,optout}_plugins _zephyr_preset _initfiles
