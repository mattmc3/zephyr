####
# syntax-highlighting - Syntax highlighting for interactive zsh sessions.
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

zsh-defer source ${0:A:h:h}/.external/fast-syntax-highlighting/init.zsh || return 1

#
# Cleanup
#

zstyle ":zephyr:plugin:syntax-highlighting" loaded 'yes'
