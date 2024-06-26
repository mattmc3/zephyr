#
# color: Make the terminal more colorful.
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

# Built-in zsh colors.
autoload -Uz colors && colors

# Colorize man pages.
export LESS_TERMCAP_md=$fg_bold[blue]   # start bold
export LESS_TERMCAP_mb=$fg_bold[blue]   # start blink
export LESS_TERMCAP_so=$'\e[00;47;30m'  # start standout: white bg, black fg
export LESS_TERMCAP_us=$'\e[04;35m'     # start underline: underline magenta
export LESS_TERMCAP_se=$reset_color     # end standout
export LESS_TERMCAP_ue=$reset_color     # end underline
export LESS_TERMCAP_me=$reset_color     # end bold/blink

# Set LS_COLORS using (g)dircolors if found.
if [[ -z "$LS_COLORS" ]]; then
  for dircolors_cmd in dircolors gdircolors; do
    if (( $+commands[$dircolors_cmd] )); then
      if zstyle -t ':zephyr:feature:color' 'use-cache'; then
        cached-command "$dircolors_cmd" $dircolors_cmd --sh
      else
        source <($dircolors_cmd --sh)
      fi
      break
    fi
  done
  # Or, pick a reasonable default.
  export LS_COLORS="${LS_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
fi

# Missing dircolors is a good indicator of a BSD system. Set LSCOLORS for macOS/BSD.
if (( ! $+commands[dircolors] )); then
  # For BSD systems, set LSCOLORS
  export CLICOLOR=${CLICOLOR:-1}
  export LSCOLORS="${LSCOLORS:-exfxcxdxbxGxDxabagacad}"
fi

# Set functions.
if ! zstyle -t ':zephyr:plugin:color:function' skip; then
  autoload-dir ${0:a:h}/functions
fi

# Set aliases.
if ! zstyle -t ':zephyr:plugin:color:alias' skip; then
  # Set colors for grep.
  alias grep="${aliases[grep]:-grep} --color=auto"

  # Set colors for coreutils ls.
  if (( $+commands[gls] )); then
    alias gls="${aliases[gls]:-gls} --group-directories-first --color=auto"
  fi

  # Set colors for ls.
  if (( ! $+commands[dircolors] )) || [[ "$OSTYPE" == darwin* ]]; then
    alias ls="${aliases[ls]:-ls} -G"
  else
    alias ls="${aliases[ls]:-ls} --group-directories-first --color=auto"
  fi

  # Set colors for diff
  if command diff --color /dev/null{,} &>/dev/null; then
    alias diff="${aliases[diff]:-diff} --color"
  fi
fi

# Colorize completions.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:color' loaded 'yes'
