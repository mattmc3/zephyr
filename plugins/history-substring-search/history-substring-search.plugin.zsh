#
# Requirements
#

0=${(%):-%x}
if ! (( $+functions[zephyrinit] )); then
  autoload -Uz ${0:A:h:h:h}/functions/zephyrinit && zephyrinit
fi

#
# Init
#

source $ZEPHYR_HOME/.external/zsh-history-substring-search/zsh-history-substring-search.zsh

#
# Keybinds
#

# emacs
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# vi
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down

# up/down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
