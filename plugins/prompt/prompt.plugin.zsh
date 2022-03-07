#
# Add Zephyr prompts to fpath
#

_zephyr_autoload_funcdir ${0:a:h}/functions

#
# Options
#

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#
# Init
#

autoload -Uz promptinit && promptinit
