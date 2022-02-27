#
# Variables
#

ZEPHYRDIR=${0:A:h}

#
# Functions
#

function zephyr-clone-external {
  local plugin_name=$1
  local repo=$2
  local plugin_dir=$ZEPHYRDIR/plugins/$plugin_name/external/${2:t}
  local initfile initfiles
  if [[ ! -d $plugin_dir ]]; then
    git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    initfile=$plugin_dir/${2:t}.plugin.zsh
    if [[ ! -e $initfile ]]; then
      initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      [[ ${#initfiles[@]} -gt 0 ]] && ln -sf ${initfiles[1]} $initfile
    fi
  fi
}

function zephyr-update {
  echo "Updating zephyr..."
  git -C "$ZEPHYRDIR" pull
  local d
  for d in $ZEPHYRDIR/plugins/**/external/*/.git/..; do
    echo "Updating ${d:A:t}..."
    git -C "${d:A}" pull
  done
}

#
# Default plugins
#

if ! (( $#plugins )); then
  plugins=(
    environment
    terminal
    editor
    history
    directory
    utility
    abbreviations
    autosuggestions
    history-substring-search
    zfunctions
    confd
    completions
    prompt
    syntax-highlighting
  )
fi

for plugin in $plugins; do
  plugin_dir=$ZEPHYRDIR/plugins/$plugin
  if [[ ! -d $plugin_dir ]]; then
    echo "Plugin not found '$plugin'"
    continue
  fi
  source $plugin_dir/$plugin.plugin.zsh
  if [[ -d $plugin_dir/functions ]]; then
    fpath+="$plugin_dir/functions"
    for f in $plugin_dir/functions/*(.N); do
      autoload -Uz $f
    done
    unset f
  fi
done
unset plugin plugin_dir
