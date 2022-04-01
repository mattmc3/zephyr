#
# Autosuggestions for Zsh commands.
#

#region: Requirements
[[ "$TERM" != 'dumb' ]] || return 1
#endregion

#region: Init
0=${(%):-%x}
zstyle -t ':zephyr:core' initialized || source ${0:A:h:h:h}/lib/init.zsh
#endregion

#region: External
source "$ZEPHYR_HOME/.external/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh"
# endregion

#region: Variables
zstyle -s ':zephyr:plugin:autosuggestions:color' found \
  'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE' || ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
# endregion

#region: Key Bindings
if [[ -n "$key_info" ]]; then
  # vi
  bindkey -M viins "$key_info[Control]F" vi-forward-word
  bindkey -M viins "$key_info[Control]E" vi-add-eol
fi
# endregion
