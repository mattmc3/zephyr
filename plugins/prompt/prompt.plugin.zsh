#
# prompt: Set zsh prompt.
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
fpath=(${0:a:h}/functions $fpath)

if zstyle -t ':zephyr:plugin:prompt' transient; then
  setopt transient_rprompt
  function zle-line-init() {
    emulate -L zsh

    [[ $CONTEXT == start ]] || return 0
    while true; do
      zle .recursive-edit
      local -i ret=$?
      [[ $ret == 0 && $KEYS == $'\4' ]] || break
      [[ -o ignore_eof ]] || exit 0
    done

    local saved_prompt=$PROMPT
    local saved_rprompt=$RPROMPT

    local magenta bold off
    if command -v tput >/dev/null; then
      magenta="$(tput setaf 5)"
      bold="$(tput bold)"
      off="$(tput sgr0)"
    fi

    PROMPT="${magenta}${bold}%# ${off}"
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt

    if (( ret )); then
      zle .send-break
    else
      zle .accept-line
    fi
    return ret
  }
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

#
# Wrap up
#

zstyle ":zephyr:plugin:prompt" loaded 'yes'
