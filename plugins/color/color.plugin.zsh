#
# color - Make terminal things more colorful
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
-zephyr-autoload-dir ${0:a:h}/functions

# Colorize man pages.
# start/end - md/me:bold; us/ue:underline; so/se:standout;
# colors    - 0-black; 1-red; 2-green; 3-yellow; 4-blue; 5-magenta; 6-cyan; 7-white;
export LESS_TERMCAP_mb=$'\e[01;36m'
export LESS_TERMCAP_md=$'\e[01;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[00;47;30m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[04;35m'

# Set ls colors and alias via dircolors.
function -coreutils-alias-setup {
  emulate -L zsh; setopt local_options extended_glob

  # Prefix will either be g or empty. This is to account for GNU Coreutils being
  # installed alongside BSD Coreutils
  local prefix=$1

  # Cache results of running dircolors for 20 hours, so it should almost
  # always regenerate the first time a shell is opened each day.
  local dircolors_cache=$__zephyr_cache_dir/${prefix}dircolors.zsh
  local cache_files=($dircolors_cache(Nmh-20))
  if ! (( $#cache_files )); then
    ${prefix}dircolors --sh > $dircolors_cache
  fi
  source "${dircolors_cache}"

  alias ${prefix}ls="${aliases[${prefix}ls]:-${prefix}ls} --group-directories-first --color=auto"
}

# dircolors is a surprisingly good way to detect GNU vs BSD coreutils
if (( $+commands[gdircolors] )); then
  -coreutils-alias-setup g
fi

if (( $+commands[dircolors] )); then
  -coreutils-alias-setup
else
  alias ls="${aliases[ls]:-ls} -G"
fi

# Colorize grep.
alias grep="${aliases[grep]:-grep} --color=auto"

# Colorize utils.
alias colormap='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'

# Colorize completions.
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Clean up.
unfunction -- -coreutils-alias-setup

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:color" loaded 'yes'
