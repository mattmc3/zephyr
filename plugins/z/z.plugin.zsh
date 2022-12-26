###
# z - Jump around with rupa/z.
###

#
# Requirements
#

0=${(%):-%x}
: ${ZEPHYR_HOME:=${0:A:h:h:h}}
zstyle -t ':zephyr:core' initialized || . $ZEPHYR_HOME/lib/init.zsh

#
# Init
#

source $ZEPHYR_HOME/.external/z/z.sh
if [[ -z "$_Z_DATA" ]]; then
  _Z_DATA=${XDG_DATA_HOME:=$HOME/.local/share}/z/data
fi
[[ -f $_Z_DATA ]] || { mkdir -p ${_Z_DATA:h} && touch $_Z_DATA }
