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

# if zstyle -t ':zephyr:plugin:prompt:starship' transient; then
#   setopt transient_rprompt
#   source ${0:a:h}/starship_transient_prompt.zsh
#   zle -N zle-line-init
# fi

function promptinit {
  # Initialize real built-in prompt system.
  unfunction promptinit prompt &>/dev/null
  autoload -Uz promptinit && promptinit "$@"

  # If we're here, it's because the user manually ran promptinit, which means we
  # no longer need the failsafe hook.
  hooks-add-hook -d post_zshrc run-promptinit-post-zshrc
}

# Wrap promptinit.
function run-promptinit {
  # Initialize real built-in prompt system.
  unfunction promptinit prompt &>/dev/null
  autoload -Uz promptinit && promptinit

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
}

# Failsafe to make sure promptinit runs during the post_zshrc event
function run-promptinit-post-zshrc {
  run-promptinit
  hooks-add-hook -d post_zshrc run-promptinit-post-zshrc
}
hooks-add-hook post_zshrc run-promptinit-post-zshrc

# Mark this plugin as loaded.
zstyle ":zephyr:plugin:prompt" loaded 'yes'
