#
# prompt: Set zsh prompt.
#

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

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
fpath=(${0:a:h}/functions $fpath)

if zstyle -t ':zephyr:plugin:prompt:starship' transient; then
  setopt transient_rprompt
  source ${0:a:h}/starship_transient_prompt.zsh
  zle -N zle-line-init
fi

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

# Keep prompt array sorted.
prompt_themes=( "${(@on)prompt_themes}" )

# Mark this plugin as loaded.
zstyle ":zephyr:plugin:prompt" loaded 'yes'
