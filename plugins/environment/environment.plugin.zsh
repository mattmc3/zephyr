###
# environment - Set general shell options and define environment variables.
###

#
# Variables
#

# Set XDG base dirs.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-~/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-~/.local/share}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-~/.xdg}

# Ensure XDG dirs exist.
for _xdir in $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_RUNTIME_DIR
do
  [[ -d "$_xdir" ]] || mkdir -p $_xdir
done
unset _xdir

# Browser
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER=${BROWSER:-open}
fi

# Set editors.
export EDITOR=${EDITOR:-vim}
export VISUAL=${VISUAL:-vim}
export PAGER=${PAGER:-less}

# Regional settings
export LANG=${LANG:-en_US.UTF-8}

# Ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# Set the default Less options.
# Mouse-wheel scrolling is disabled with -X (disable screen clearing)
# Add -X to disable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -z-4'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="${LESSOPEN:-| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-}"
fi

# Use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER
