#
# External
#

[[ -d $ZEPHYRDIR/contribs/zsh-autosuggestions ]] || _zephyr_clone zsh-users/zsh-autosuggestions
source $ZEPHYRDIR/contribs/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

#
# Highlighting
#

# set highlight color, default 'fg=8'.
zstyle -s ':zephyr:plugin:autosuggestions:color' found \
  'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE' || ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# disable highlighting
if ! zstyle -t ':zephyr:plugin:autosuggestions' color; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=''
fi

#
# Keybindings
#

if [[ -n "$key_info" ]]; then
  # vi
  bindkey -M viins "$key_info[Control]F" vi-forward-word
  bindkey -M viins "$key_info[Control]E" vi-add-eol
fi
