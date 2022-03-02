#
# External
#

_zephyr_clone_plugin ohmyzsh/ohmyzsh
_zephyr_clone_plugin romkatv/powerlevel10k
_zephyr_clone_plugin sindresorhus/pure

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
