#
# Variables
#

ZEPHYRDIR=${0:A:h}

#
# Functions
#

function -zephyr-clone-subplugin {
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

zstyle -a ':zephyr:load' plugins \
  'zplugins' \
    || zplugins=($zplugins_default)

for zplugin in $zplugins; do
  zplugin_dir=$ZEPHYRDIR/plugins/$zplugin
  if [[ ! -d $zplugin_dir ]]; then
    echo "Plugin not found '$zplugin'"
    continue
  fi
  source $zplugin_dir/$zplugin.plugin.zsh
  if [[ -d $zplugin_dir/functions ]]; then
    fpath+="$zplugin_dir/functions"
    for f in $zplugin_dir/functions/*(.N); do
      autoload -Uz $f
    done
    unset f
  fi
done
unset zplugin{s,s_default,_dir,}
