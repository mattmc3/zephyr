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

source ${0:a:h}/external/zsh-z/zsh-z.plugin.zsh
ZSHZ_DATA=${XDG_DATA_HOME:=$HOME/.local/share}/zsh-z/data
[[ -f $ZSHZ_DATA ]] || { mkdir -p ${ZSHZ_DATA:h} && touch $ZSHZ_DATA }

# if [[ -z "$_Z_DATA" ]]; then
#   _Z_DATA=${XDG_DATA_HOME:=$HOME/.local/share}/z/data
# fi
# [[ -f $_Z_DATA ]] || { mkdir -p ${_Z_DATA:h} && touch $_Z_DATA }
