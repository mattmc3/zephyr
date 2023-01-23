###
# zman - fzf search Zsh documentation.
####

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

# Autoload functions.
fpath=(${0:A:h}/functions $fpath)
autoload -U $fpath[1]/*(.:t)

#
# Wrap up
#

zstyle ":zephyr:plugin:zman" loaded 'yes'
