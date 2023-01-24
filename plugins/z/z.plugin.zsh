###
# z - Jump quickly to directories that you have visited "frecently."
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

ZSHZ_DATA=${XDG_DATA_HOME:=$HOME/.local/share}/zsh-z/data
[[ -f $ZSHZ_DATA ]] || { mkdir -p ${ZSHZ_DATA:h} && touch $ZSHZ_DATA }

source ${0:A:h}/lib/zsh-z.zsh || return 1

#
# Wrap up
#

zstyle ":zephyr:plugin:z" loaded 'yes'
