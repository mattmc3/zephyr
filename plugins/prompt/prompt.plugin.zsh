####
# prompt - Set zsh prompt.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%x}
: ${ZEPHYR_HOME:=${0:A:h:h:h}}
zstyle -t ':zephyr:core' initialized || . $ZEPHYR_HOME/lib/init.zsh

#
# Options
#

setopt PROMPT_SUBST  # Expand parameters in prompt.

#
# Variables
#

# use 2 space indent for each new level
PS2='${${${(%):-%_}//[^ ]}// /  }    '

#
# Init
#

# set prompt
fpath+="${0:A:h}/functions"
autoload -Uz promptinit && promptinit
[[ -z "$ZSH_THEME" ]] || prompt $ZSH_THEME
