#
# environment - Set general shell options and define environment variables.
#

# Set XDG base dirs.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Fish-like Zsh vars
export __zsh_config_dir=${__zsh_config_dir:-${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}}
export __zsh_user_data_dir=${__zsh_user_data_dir:-$XDG_DATA_HOME/zsh}
export __zsh_cache_dir=${__zsh_cache_dir:-$XDG_CACHE_HOME/zsh}

# Ensure dirs exist.
() {
  local _d
  for _d in $@; do
    [[ -d ${(P)_d} ]] || mkdir -p ${(P)_d}
  done
} XDG_{CONFIG,CACHE,DATA,STATE}_HOME __zsh_{config,user_data,cache}_dir

# Editors
export EDITOR=${EDITOR:-nano}
export VISUAL=${VISUAL:-nano}
export PAGER=${PAGER:-less}

# Set browser.
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER=${BROWSER:-open}
fi

# Set language.
export LANG=${LANG:-en_US.UTF-8}

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  $HOME/{,s}bin(N)
  $HOME/brew/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# Set the default Less options.
# Mouse-wheel scrolling can be disabled with -X (disable screen clearing).
# Add -X to disable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -z-4'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# Reduce key delay
export KEYTIMEOUT=${KEYTIMEOUT:-1}

# Make Apple Terminal behave.
if [[ "$OSTYPE" == darwin* ]]; then
  export SHELL_SESSIONS_DISABLE=${SHELL_SESSIONS_DISABLE:-1}
fi

# Use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:environment' loaded 'yes'
