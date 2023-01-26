####
# prompt - Set zsh prompt.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Options
#

setopt PROMPT_SUBST  # Expand parameters in prompt.

#
# Variables
#

# Set 2 space indent for each new level in a multi-line script
# This can then be overridden by a prompt, but is a better default than zsh's
PS2='${${${(%):-%_}//[^ ]}// /  }    '

#
# Init
#

# Autoload functions.
fpath=(${0:A:h}/functions $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Use zstyle for the prompt theme.
zstyle -s ':zephyr:plugin:prompt' theme 'theme_name' ||
  theme_name=${ZSH_THEME:-starship}

# Use zstyle to get the preferred starship prompt theme.
if [[ "$theme_name" == starship ]] &&
   zstyle -s ':zephyr:plugin:prompt:starship' config _toml
then
  export STARSHIP_CONFIG=${0:A:h}/themes/${_toml}.toml
  unset _toml
fi

# Run the prompt setup function directly, or use the promptinit system.
if (( $+functions[prompt_${theme_name}_setup] )); then
  prompt_${theme_name}_setup
else
  autoload -Uz promptinit && promptinit
  [[ -z "$theme_name" ]] || prompt $theme_name
fi

#
# Wrap up
#

unset theme_name
zstyle ":zephyr:plugin:prompt" loaded 'yes'
