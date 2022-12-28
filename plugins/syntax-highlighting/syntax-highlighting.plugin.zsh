####
# syntax-highlighting - Syntax highlighting for interactive zsh sessions.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Init
#

# TODO: allow user to select zsh-syntax-highlighting or fast-syntax-highlighting
#_initfile=${0:a:h}/external/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
_initfile=${0:a:h}/external/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

(( $+functions[zsh-defer] )) && zsh-defer . $_initfile || . $_initfile

#
# Cleanup
#

unset _initfile
