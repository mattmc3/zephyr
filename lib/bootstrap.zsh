#
# bootstrap: Ensure Zephyr is properly boostrapped.
#

# Set ZEPHYR_HOME.
0=${(%):-%N}
: ${ZEPHYR_HOME:=${0:a:h:h}}

# Set critical Zsh options.
setopt extended_glob interactive_comments

# Set Zsh locations.
typeset -gx __zsh_{config,cache,user_data}_dir
: ${__zsh_config_dir:=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}
: ${__zsh_cache_dir:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}
: ${__zsh_user_data_dir:=${XDG_DATA_HOME:-$HOME/.local/share}/zsh}
mkdir -p $__zsh_config_dir $__zsh_user_data_dir $__zsh_cache_dir

# Support for hooks.
source ${0:a:h}/zsh-hooks.zsh

# There's not really a post_zshrc event, so we're going to fake one by adding it
# as a one-time precmd event, and then unregistering it.
hooks-define-hook 'post_zshrc'
function post_zshrc_hook {
  # Run once
  hooks-run-hook post_zshrc
  # Now remove this hook so that it doesn't keep running on every precmd event.
  add-zsh-hook -d precmd post_zshrc_hook
  unfunction -- post_zshrc_hook
}
add-zsh-hook precmd post_zshrc_hook

# Load helper functions.
zstyle -t ':zephyr:plugin:helper' loaded \
  || source $ZEPHYR_HOME/plugins/helper/helper.plugin.zsh

# Mark this lib as loaded.
zstyle ":zephyr:lib:bootstrap" loaded 'yes'
