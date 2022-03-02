#
# External
#

-zephyr-clone ohmyzsh/ohmyzsh
-zephyr-clone romkatv/powerlevel10k
-zephyr-clone sindresorhus/pure

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
