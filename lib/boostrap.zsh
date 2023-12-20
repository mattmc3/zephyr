#
# bootstrap: Ensure Zephyr is properly boostrapped.
#

# Set Zephyr vars.
0=${(%):-%N}
ZEPHYR_HOME=${0:a:h:h}

# Set Zsh locations.
typeset -gx __zsh_config_dir
zstyle -s ':zephyr:zsh:config' dir '__zsh_config_dir' \
  || __zsh_config_dir=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}

typeset -gx __zsh_user_data_dir
zstyle -s ':zephyr:zsh:user_data' dir '__zsh_user_data_dir' \
  || __zsh_user_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh

typeset -gx __zsh_cache_dir
zstyle -s ':zephyr:zsh:cache' dir '__zsh_cache_dir' \
  || __zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh

# Tell Zephyr this lib is loaded.
zstyle ":zephyr:lib:bootstrap" loaded 'yes'
