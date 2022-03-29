#region: Requirements

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%x}

#endregion

#region: External

if [[ ! -d "${0:A:h}/external/zsh-autosuggestions" ]]; then
  command git clone --quiet --depth 1 \
    https://github.com/zsh-users/zsh-autosuggestions \
    "${0:A:h}/external/zsh-autosuggestions"
fi
source "${0:A:h}/external/zsh-autosuggestions/zsh-autosuggestions.zsh"

# endregion

#region: Variables

# Set highlight color, default 'fg=8'.
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
