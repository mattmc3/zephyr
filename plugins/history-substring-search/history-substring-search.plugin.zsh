#
# Integrates history-substring-search into Zephyr.
#

#region: Requirements
[[ "$TERM" != 'dumb' ]] || return 1
#endregion

#region: Init
0=${(%):-%x}
zstyle -t ':zephyr:core' initialized || source ${0:A:h:h:h}/lib/init.zsh
#endregion

#region: External
source "$ZEPHYR_HOME/.external/zsh-users/zsh-history-substring-search/zsh-history-substring-search.zsh"
# endregion

#region: Variables
zstyle -s ':zephyr:plugin:history-substring-search:color' found \
  'HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND' \
    || HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'

zstyle -s ':zephyr:plugin:history-substring-search:color' not-found \
  'HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND' \
    || HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'

zstyle -s ':zephyr:plugin:history-substring-search' globbing-flags \
  'HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS' \
    || HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

if zstyle -t ':zephyr:plugin:history-substring-search' case-sensitive; then
  HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS="${HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS//i}"
fi

if ! zstyle -t ':zephyr:plugin:history-substring-search' color; then
  unset HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_{FOUND,NOT_FOUND}
fi
#endregion

#region: Key Bindings
if [[ -n "$key_info" ]]; then
  # Emacs
  bindkey -M emacs "$key_info[Control]P" history-substring-search-up
  bindkey -M emacs "$key_info[Control]N" history-substring-search-down

  # Vi
  bindkey -M vicmd "k" history-substring-search-up
  bindkey -M vicmd "j" history-substring-search-down

  # Emacs and Vi
  for keymap in 'emacs' 'viins'; do
    bindkey -M "$keymap" "$key_info[Up]" history-substring-search-up
    bindkey -M "$keymap" "$key_info[Down]" history-substring-search-down
  done

  unset keymap
fi
#endregion
