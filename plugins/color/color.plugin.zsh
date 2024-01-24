#
# color - Make terminal things more colorful
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

# Set functions.
if ! zstyle -t ':zephyr:plugin:color:function' skip; then
  autoload-dir ${0:a:h}/functions
fi

# Colorize man pages.
# mb/me := start/end blink mode      md/me := start/end bold mode
# so/se := start/end standout mode   us/ue := start/end underline mode
# 0-black, 1-red, 2-green, 3-yellow, 4-blue, 5-magenta, 6-cyan, 7-white
export LESS_TERMCAP_mb=$'\e[01;36m'
export LESS_TERMCAP_md=$'\e[01;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[00;47;30m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[04;35m'

# Set LS_COLORS using (g)dircolors if found.
local dircolors_cmds=(
  $commands[dircolors](N) $commands[gdircolors](N)
)
if [[ -z "$LS_COLORS" ]] && (( $#dircolors_cmds )); then
  cached-command "${dircolors_cmds[1]:t}" $dircolors_cmds[1] --sh
fi

# Missing dircolors is a good indicator of a BSD system.
if (( ! $+commands[dircolors] )) || [[ "$OSTYPE" == darwin* ]]; then
  # For BSD systems, set LSCOLORS
  export CLICOLOR=1
  export LSCOLORS="${LSCOLORS:-exfxcxdxbxGxDxabagacad}"
  # Also set LS_COLORS for good measure when gdircolors from coreutils is not installed.
  export LS_COLORS="${LS_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43}"
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
fi

# Colorize completions.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Mark this plugin as loaded.
zstyle ":zephyr:plugin:color" loaded 'yes'
