###
# z - Jump around with rupa/z.
###

#
# Requirements
#

zstyle -t ':zephyr:core' initialized || return 1
[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

source $ZEPHYR_HOME/.external/z/z.sh
if [[ -z "$_Z_DATA" ]]; then
  _Z_DATA=${XDG_DATA_HOME:=$HOME/.local/share}/z/data
fi
[[ -f $_Z_DATA ]] || { mkdir -p ${_Z_DATA:h} && touch $_Z_DATA }
