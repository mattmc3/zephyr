#
# Variables
#

ZEPHYRDIR=${0:A:h}

#
# Functions
#

declare -A _zephyr_loaded_plugins
function -zephyr-load-plugin {
  # variables in this function need to not conflict with ones in loaded plugins
  local _zephyr_plugin=$1
  local _zephyr_opts=${2:-none}

  # ensure we don't double-load a plugin
  if (($+_zephyr_loaded_plugins[$_zephyr_plugin])); then
    return
  fi

  # determine whether this is a zephyr or external plugin
  local _zephyr_plugin_dir
  if [[ $_zephyr_plugin = */* ]]; then
    _zephyr_plugin_dir=$ZEPHYRDIR/.external/${_zephyr_plugin:t}
    [[ -d $_zephyr_plugin_dir ]] || -zephyr-clone $_zephyr_plugin
    _zephyr_plugin=${_zephyr_plugin:t}
  else
    _zephyr_plugin_dir=$ZEPHYRDIR/plugins/$_zephyr_plugin
  fi

  if [[ ! -d $_zephyr_plugin_dir ]]; then
    echo >&2 "Plugin not found '$_zephyr_plugin'" && return 1
  fi

  # load the plugin
  if [[ $_zephyr_opts = 'defer' ]]; then
    (( ${+functions[zsh-defer]} )) || -zephyr-load-plugin romkatv/zsh-defer
    zsh-defer source $_zephyr_plugin_dir/$_zephyr_plugin.plugin.zsh
  else
    source $_zephyr_plugin_dir/$_zephyr_plugin.plugin.zsh
  fi
  if [[ -d $_zephyr_plugin_dir/functions ]]; then
    fpath+="$_zephyr_plugin_dir/functions"
    local f
    for f in $_zephyr_plugin_dir/functions/*(.N); do
      autoload -Uz $f
    done
  fi

  _zephyr_loaded_plugins[$_zephyr_plugin]=true
}

function -zephyr-clone {
  local repo=$1
  local plugin_dir=$ZEPHYRDIR/.external/${1:t}
  if [[ ! -d $plugin_dir ]]; then
    git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    local initfile=$plugin_dir/${1:t}.plugin.zsh
    if [[ ! -e $initfile ]]; then
      local initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      [[ ${#initfiles[@]} -gt 0 ]] && ln -sf ${initfiles[1]} $initfile
    fi
  fi
}

function zephyr-update {
  local d
  for d in $ZEPHYRDIR/**/.git/..; do
    echo "Updating ${d:A:t}..."
    git -C "${d:A}" pull --ff --rebase --autostash
  done
}

#
# Plugins
#

zplugins_default=(
  environment
  terminal
  editor
  history
  directory
  utility
  abbreviations
  autosuggestions
  history-substring-search
  prompt
  zfunctions
  confd
  completions
  syntax-highlighting
)

zstyle -a ':zephyr:clone' plugins \
  'zplugins_clone' \
    || zplugins_clone=()
for zplugin in $zplugins_clone; do
  -zephyr-clone $zplugin
done

zstyle -a ':zephyr:load' plugins \
  'zplugins' \
    || zplugins=($zplugins_default)
zstyle -a ':zephyr:load' additional-plugins \
  'zplugins_addtl' \
    || zplugins_addtl=()
for zplugin in $zplugins $zplugins_addtl; do
  -zephyr-load-plugin $zplugin
done

zstyle -a ':zephyr:defer' plugins \
  'zplugins_defer' \
    || zplugins_defer=()
for zplugin in $zplugins_defer; do
  -zephyr-load-plugin $zplugin defer
done

unset zplugin{s,s_default,s_addtl,s_clone,s_defer,} _zephyr_loaded_plugins
