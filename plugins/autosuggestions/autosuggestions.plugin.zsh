#
# External
#

zephyr-clone-external autosuggestions zsh-users/zsh-autosuggestions
source ${0:A:h}/external/zsh-autosuggestions/zsh-autosuggestions.zsh

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
