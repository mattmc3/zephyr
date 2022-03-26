#
# Add Zephyr prompts to fpath
#

0=${(%):-%x}
fpath+="${0:A:h}/functions"

#
# Options
#

# http://zsh.sourceforge.net/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST  # expand parameters in prompt variables

#
# Init
#

autoload -Uz promptinit && promptinit
