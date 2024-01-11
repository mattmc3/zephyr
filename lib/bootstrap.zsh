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
[[ -d $__zsh_config_dir ]] || mkdir -p $__zsh_config_dir

typeset -gx __zsh_user_data_dir
zstyle -s ':zephyr:zsh:user_data' dir '__zsh_user_data_dir' \
  || __zsh_user_data_dir=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
[[ -d $__zsh_user_data_dir ]] || mkdir -p $__zsh_user_data_dir

typeset -gx __zsh_cache_dir
zstyle -s ':zephyr:zsh:cache' dir '__zsh_cache_dir' \
  || __zsh_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh

typeset -gx __zephyr_cache_dir
zstyle -s ':zephyr:cache' dir '__zephyr_cache_dir' \
  || __zephyr_cache_dir=$__zsh_cache_dir/zephyr
[[ -d $__zephyr_cache_dir ]] || mkdir -p $__zephyr_cache_dir

# Function for autoload dir.
function -zephyr-autoload-dir {
  [[ -d "${1}" ]] || return 1
  fpath=("${1}" $fpath)
  autoload -Uz "${1}"/*(.:t)
}

# Tell Zephyr this lib is loaded.
zstyle ":zephyr:lib:bootstrap" loaded 'yes'
