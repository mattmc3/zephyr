#
# External
#

-zephyr-clone miekg/lean
-zephyr-clone ohmyzsh/ohmyzsh
-zephyr-clone romkatv/powerlevel10k
-zephyr-clone sindresorhus/pure

fpath+="$ZEPHYRDIR/.external/lean"
fpath+="$ZEPHYRDIR/.external/powerlevel10k"
fpath+="$ZEPHYRDIR/.external/pure"

#
# Options
#

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#
# Init
#

fpath+="${0:A:h}/functions"
autoload -Uz promptinit && promptinit
zstyle -a ':zephyr:plugin:prompt' theme 'prompt_argv'
if [[ "$TERM" == (dumb|linux|*bsd*) ]] || (( $#prompt_argv < 1 )); then
  prompt 'off'
else
  prompt "$prompt_argv[@]"
fi
unset prompt_argv

#
# Formatting
#

# https://unix.stackexchange.com/questions/685666/zsh-how-do-i-remove-block-prefixes-when-writing-multi-line-statements-in-intera
# use 2 space indent for each new level
PS2='${${${(%):-%_}//[^ ]}// /  }    '
