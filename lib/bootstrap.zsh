#
# bootstrap: Ensure Zephyr is properly boostrapped.
#

# Set common vars.
0=${(%):-%N}
ZEPHYR_HOME=${0:a:h:h}

# Critical Zsh options
setopt extended_glob interactive_comments

# Load core zephyr functions.
fpath=($ZEPHYR_HOME/functions $fpath)
autoload -Uz $ZEPHYR_HOME/functions/*(.:t)

# Set Zsh locations.
typeset -gx __zsh_{config,cache,user_data}_dir
if [[ -z "$__zsh_config_dir" ]]; then
  zstyle -s ':zephyr:xdg:config' dir '__zsh_config_dir' \
    || __zsh_config_dir=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
  __zsh_config_dir=${~__zsh_config_dir}
fi
if [[ -z "$__zsh_user_data_dir" ]]; then
  zstyle -s ':zephyr:xdg:user_data' dir '__zsh_user_data_dir' \
    || __zsh_user_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
  __zsh_user_data_dir=${~__zsh_user_data_dir}
fi
if [[ -z "$__zsh_cache_dir" ]]; then
  zstyle -s ':zephyr:xdg:cache' dir '__zsh_cache_dir' \
    || __zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
  __zsh_cache_dir=${~__zsh_cache_dir}
fi

# Support for hooks.
autoload -Uz add-zsh-hook

##? Checks if a file can be autoloaded by trying to load it in a subshell.
function is-autoloadable {
  ( unfunction "$1"; autoload -U +X "$1" ) &> /dev/null
}

##? Checks if a name is a command, function, or alias.
function is-callable {
  (( $+commands[$1] || $+functions[$1] || $+aliases[$1] || $+builtins[$1] ))
}

##? Check whether a string represents "true" (1, y, yes, t, true, o, on).
function is-true {
  [[ -n "$1" && "$1:l" == (1|y(es|)|t(rue|)|o(n|)) ]]
}

# OS checks.
function is-macos  { [[ "$OSTYPE" == darwin* ]] }
function is-linux  { [[ "$OSTYPE" == linux*  ]] }
function is-bsd    { [[ "$OSTYPE" == *bsd*   ]] }
function is-cygwin { [[ "$OSTYPE" == cygwin* ]] }
function is-termux { [[ "$OSTYPE" == linux-android ]] }

# Mark this lib as loaded.
zstyle ":zephyr:lib:bootstrap" loaded 'yes'
