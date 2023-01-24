####
# history-substring-search - Zsh port of Fish history search (up arrow).
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

if ! zstyle -t ':zephyr:core' initialized; then
  source ${0:A:h:h}/zephyr/zephyr.plugin.zsh
fi

#
# Init
#

source ${0:A:h}/lib/zsh-history-substring-search.zsh || return 1

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

#
# Wrap up
#

zstyle ":zephyr:plugin:history-substring-search" loaded 'yes'
