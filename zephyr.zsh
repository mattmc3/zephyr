#
# Variables
#

ZEPHYRDIR=${0:A:h}

#
# Functions
#

declare -A _zephyr_loaded_plugins
function _zephyr_load_plugin {
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
    [[ -d $_zephyr_plugin_dir ]] || _zephyr_clone_plugin $_zephyr_plugin
    _zephyr_plugin=${_zephyr_plugin:t}
  else
    _zephyr_plugin_dir=$ZEPHYRDIR/plugins/$_zephyr_plugin
  fi

  if [[ ! -d $_zephyr_plugin_dir ]]; then
    echo >&2 "Plugin not found '$_zephyr_plugin'" && return 1
  fi

  # load the plugin
  if [[ $_zephyr_opts = 'defer' ]]; then
    (( ${+functions[zsh-defer]} )) || _zephyr_load_plugin romkatv/zsh-defer
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

function _zephyr_clone_plugin {
  local repo=$1
  local plugin_dir=$ZEPHYRDIR/.external/${1:t}
  if [[ ! -d $plugin_dir ]]; then
    echo "Cloning plugin $repo..."
    git clone --quiet --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    local initfile=$plugin_dir/${1:t}.plugin.zsh
    if [[ ! -e $initfile ]]; then
      local initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      [[ ${#initfiles[@]} -gt 0 ]] && ln -sf ${initfiles[1]} $initfile
    fi
  fi
}

function _zephyr_clone_prompt {
  local repo=$1
  local prompt_dir=$ZEPHYRDIR/.prompts/${1:t}
  if [[ ! -d $prompt_dir ]]; then
    echo "Cloning prompt $repo..."
    git clone --quiet --depth 1 --recursive --shallow-submodules https://github.com/$repo $prompt_dir
    local initfile=$prompt_dir/prompt_${1:t}_setup
    if [[ ! -e $initfile ]]; then
      local initfiles=($prompt_dir/*.zsh-theme(N))
      [[ ${#initfiles[@]} -gt 0 ]] && echo ". ${initfiles[1]}" >| $initfile
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
  prompt
  zfunctions
  confd
  completions
  syntax-highlighting
  history-substring-search
  autosuggestions
)

zstyle -a ':zephyr:clone' plugins \
  'zplugins_clone' \
    || zplugins_clone=()
for zplugin in $zplugins_clone; do
  _zephyr_clone_plugin $zplugin
done

zstyle -a ':zephyr:load' additional-plugins \
  'zplugins_addtl' \
    || zplugins_addtl=()
zstyle -a ':zephyr:load' plugins \
  'zplugins' \
    || zplugins=($zplugins_default)
for zplugin in $zplugins_addtl $zplugins; do
  _zephyr_load_plugin $zplugin
done

zstyle -a ':zephyr:defer' plugins \
  'zplugins_defer' \
    || zplugins_defer=()
for zplugin in $zplugins_defer; do
  _zephyr_load_plugin $zplugin defer
done

unset zplugin{s,s_default,s_addtl,s_clone,s_defer,} _zephyr_loaded_plugins
unfunction _zephyr_load_plugin _zephyr_clone_{plugin,prompt}
