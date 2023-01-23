####
# clipboard - Handy cross-platform clipboard functions.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

source ${0:A:h:h}/.external/ohmyzsh/lib/clipboard.zsh || return 1
source ${0:A:h:h}/.external/ohmyzsh/plugins/copybuffer/copybuffer.plugin.zsh || return 1
source ${0:A:h:h}/.external/ohmyzsh/plugins/copyfile/copyfile.plugin.zsh || return 1
source ${0:A:h:h}/.external/ohmyzsh/plugins/copypath/copypath.plugin.zsh || return 1
