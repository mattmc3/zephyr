####
# syntax-highlighting - Syntax highlighting for interactive zsh sessions.
###

#
# Requirements
#

zstyle -t ':zephyr:core' initialized || return 1
[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

# TODO: allow user to select zsh-syntax-highlighting or fast-syntax-highlighting
#_initfile=$ZEPHYR_HOME/.external/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
_initfile=$ZEPHYR_HOME/.external/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

(( $+functions[zsh-defer] )) && zsh-defer . $_initfile || . $_initfile

#
# Cleanup
#

unset _initfile
