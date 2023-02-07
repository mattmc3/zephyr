####
# color - Make terminal things more colorful.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Variables
#

# start/end - md/me:bold; us/ue:underline; so/se:standout;
# colors    - 0-black; 1-red; 2-green; 3-yellow; 4-blue; 5-magenta; 6-cyan; 7-white;
export LESS_TERMCAP_mb=$'\e[01;36m'
export LESS_TERMCAP_md=$'\e[01;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[00;47;30m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;35m'

#
# Init
#

fpath=(${0:A:h}/functions $fpath)
autoload -U $fpath[1]/*(.:t)

#
# Wrap up
#

zstyle ":zephyr:plugin:color" loaded 'yes'
