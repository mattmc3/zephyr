####
# colors - Make terminal things more colorful.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

0=${(%):-%x}
fpath+=${0:A:h}/functions
autoload -Uz ${0:A:h}/functions/man
autoload -Uz ${0:A:h}/functions/showcolors
