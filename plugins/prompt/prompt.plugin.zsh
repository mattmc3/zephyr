#
# prompt - Set zsh prompt.
#

#
# Variables
#

# Set 2 space indent for each new level in a multi-line script
# This can then be overridden by a prompt, but is a better default than zsh's
PS2='${${${(%):-%_}//[^ ]}// /  }    '

#
# Functions
#

# Add Zephyr's prompt functions to fpath.
0=${(%):-%N}
fpath=(${0:A:h}/functions $fpath)

# Initialize Zsh's prompt system
autoload -Uz promptinit && promptinit

#
# Init
#

# Set the prompt if specified
local -a prompt_theme
zstyle -a ':zephyr:plugin:prompt' theme 'prompt_argv'
if [[ $TERM == (dumb|linux|*bsd*) ]]; then
  prompt 'off'
elif (( $#prompt_argv > 0 )); then
  prompt "$prompt_argv[@]"
fi
unset prompt_argv

#
# Wrap up
#

zstyle ":zephyr:plugin:prompt" loaded 'yes'
