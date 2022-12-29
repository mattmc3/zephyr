####
# autosuggestions - Fish-like autosuggestions for zsh.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

# Source module files.
source "${0:a:h}/external/zsh-autosuggestions/zsh-autosuggestions.zsh" || return 1

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
