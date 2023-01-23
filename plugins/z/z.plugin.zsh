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

source ${0:A:h:h}/.external/zsh-z/init.zsh || return 1
ZSHZ_DATA=${XDG_DATA_HOME:=$HOME/.local/share}/zsh-z/data
[[ -f $ZSHZ_DATA ]] || { mkdir -p ${ZSHZ_DATA:h} && touch $ZSHZ_DATA }
