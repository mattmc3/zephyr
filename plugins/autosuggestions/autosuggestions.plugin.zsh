#
# External
#

[[ -d $ZEPHYRDIR/contribs/zsh-autosuggestions ]] || _zephyr_clone zsh-users/zsh-autosuggestions
source $ZEPHYRDIR/contribs/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

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
