#
# Variables
#

ZEPHYRDIR=${0:A:h}

#
# Functions
#

declare -A _zephyr_loaded_plugins
function -zephyr-load-plugin {
  local zplugin=$1
  local options=${2:-none}

  # ensure we don't double-load a plugin
  if (($+_zephyr_loaded_plugins[$zplugin])); then
    return
  fi

  # determine whether this is a zephyr or external plugin
  local zplugin_dir
  if [[ $zplugin = */* ]]; then
    zplugin_dir=$ZEPHYRDIR/.external/${zplugin:t}
    [[ -d $zplugin_dir ]] || -zephyr-clone $zplugin
    zplugin=${zplugin:t}
  else
    zplugin_dir=$ZEPHYRDIR/plugins/$zplugin
  fi

  if [[ ! -d $zplugin_dir ]]; then
    echo >&2 "Plugin not found '$zplugin'" && return 1
  fi

  # load the plugin
  if [[ $options = 'defer' ]]; then
    (( ${+functions[zsh-defer]} )) || -zephyr-load-plugin romkatv/zsh-defer
    zsh-defer source $zplugin_dir/$zplugin.plugin.zsh
  else
    source $zplugin_dir/$zplugin.plugin.zsh
  fi
  if [[ -d $zplugin_dir/functions ]]; then
    fpath+="$zplugin_dir/functions"
    local f
    for f in $zplugin_dir/functions/*(.N); do
      autoload -Uz $f
    done
  fi

  _zephyr_loaded_plugins[$plugin_name]=true
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
for zplugin in $zplugins; do
  -zephyr-load-plugin $zplugin
done

zstyle -a ':zephyr:defer' plugins \
  'zplugins_defer' \
    || zplugins_defer=()
for zplugin in $zplugins_defer; do
  -zephyr-load-plugin $zplugin defer
done

unset zplugin{s,s_default,s_clone,s_defer,} _zephyr_loaded_plugins
