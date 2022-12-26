####
# history-substring-search - Zsh port of Fish history search (up arrow).
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%x}
: ${ZEPHYR_HOME:=${0:A:h:h:h}}
zstyle -t ':zephyr:core' initialized || . $ZEPHYR_HOME/lib/init.zsh

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
