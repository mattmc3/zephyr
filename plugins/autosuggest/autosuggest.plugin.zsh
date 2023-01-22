####
# autosuggest - Fish-like autosuggest for zsh.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

# Source module files.
zsh_autosuggestions="${0:A:h}/external/zsh-autosuggestions"
[[ -d "$zsh_autosuggestions" ]] ||
  git clone --quiet --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_autosuggestions"
source "$zsh_autosuggestions/zsh-autosuggestions.zsh" || return 1

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
