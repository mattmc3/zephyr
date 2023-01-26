####
# autosuggestions - Fish-like autosuggestions for zsh.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

if ! zstyle -t ':zephyr:core' initialized; then
  source ${0:A:h:h}/zephyr/zephyr.plugin.zsh
fi

#
# Init
#

source ${0:A:h:h}/.external/zsh-autosuggestions/init.zsh || return 1

#
# Variables
#

# Set highlight color, default 'fg=60'.
zstyle -s ':zephyr:plugin:autosuggestions:highlight' style \
  'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE' || ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

#
# Keybinds
#

if [[ -n "$key_info" ]]; then
  # vi
  bindkey -M viins "$key_info[Control]F" vi-forward-word
  bindkey -M viins "$key_info[Control]E" vi-add-eol
fi

#
# Wrap up
#

zstyle ":zephyr:plugin:autosuggestions" loaded 'yes'
