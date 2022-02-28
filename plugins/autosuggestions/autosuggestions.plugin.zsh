#
# External
#

-zephyr-load-plugin zsh-users/zsh-autosuggestions

#
# Variables
#

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

#
# Keybindings
#

if [[ -n "$key_info" ]]; then
  # vi
  bindkey -M viins "$key_info[Control]F" vi-forward-word
  bindkey -M viins "$key_info[Control]E" vi-add-eol
fi
