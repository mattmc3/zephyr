#
# External
#

zephyr-clone-external prompt sindresorhus/pure
zephyr-clone-external prompt romkatv/powerlevel10k
zephyr-clone-external prompt miekg/lean

fpath+="${0:A:h}/external/pure"
fpath+="${0:A:h}/external/powerlevel10k"

#
# Options
#

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#
# Formatting
#

# https://unix.stackexchange.com/questions/685666/zsh-how-do-i-remove-block-prefixes-when-writing-multi-line-statements-in-intera
# use 2 space indent for each new level
PS2='${${${(%):-%_}//[^ ]}// /  }    '

#
# Init
#

fpath+="${0:A:h}/functions"
autoload -Uz promptinit && promptinit
