####
# color - Make terminal things more colorful.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

fpath=(${0:A:h}/functions $fpath)
autoload -U $fpath[1]/*(.:t)

#
# Cleanup
#

zstyle ":zephyr:plugin:color" loaded 'yes'
