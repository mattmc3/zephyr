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
zstyle -s ':zephyr:plugin:prompt' theme theme_name ||
  theme_name=${ZSH_THEME:-zephyr}

# See if we need to set STARSHIP_CONFIG
zstyle -s ':zephyr:plugin:prompt:starship' config starshipcfg ||
  starshipcfg=

# Use zstyle to set the preferred starship prompt theme.
if [[ -e "${XDG_CONFIG_HOME:=$HOME/.config}/starship/${starshipcfg}.toml" ]]; then
  STARSHIP_CONFIG="${XDG_CONFIG_HOME:=$HOME/.config}/starship/${starshipcfg}.toml"
elif [[ -n "$starshipcfg" ]]; then
  STARSHIP_CONFIG="$starshipcfg"
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

unset theme_name starshipcfg
zstyle ":zephyr:plugin:prompt" loaded 'yes'
