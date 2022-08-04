#
# Functions
#

function showcolors {
  local normal=$(tput sgr0)
  typeset -A colors=(
    0    black
    1    red
    2    green
    3    yellow
    4    blue
    5    magenta
    6    cyan
    7    white
    8    brblack
    9    brred
    10   brgreen
    11   bryellow
    12   brblue
    13   brmagenta
    14   brcyan
    15   brwhite
  )

  typeset -A effects=(
    bold       bold
    dim        dim
    italic     sitm
    reverse    rev
    standout   smso
    underline  smul
  )

  local id
  for id in ${(kno)colors}; do
    color=$colors[$id]
    printf "%5s %-25s %5s %-25s %-10s\n" $(tput setaf $id) "foreground ${color}" $(tput sgr0) "tput setaf $id" ${$(tput setaf $id):q}
  done
  for id in ${(kno)colors}; do
    color=$colors[$id]
    printf "%5s %-30s %11s %-25s %-10s\n" $(tput setab $id) "$(tput setaf 7)background $(tput setaf 0)${color}" $(tput sgr0) "tput setab $id" ${$(tput setab $id):q}
  done

  local name code
  for name in ${(kno)effects}; do
    code=$effects[$name]
    printf "%5s %-24s %5s %-25s %-10s\n" $(tput $code) "effect ${name}" $(tput sgr0) "tput $code" ${$(tput $code):q}
  done
  printf "%1s %-25s %-25s\n" "" "normal" "tput sgr0"
}

#
# Variables
#

# Colorize man pages.
export LESS_TERMCAP_mb=$'\E[01;34m'     # start blink-mode (bold,blue)
export LESS_TERMCAP_md=$'\E[01;34m'     # start bold-mode (bold,blue)
export LESS_TERMCAP_so=$'\E[00;47;30m'  # start standout-mode (white bg, black fg)
export LESS_TERMCAP_se=$'\E[0m'         # end standout-mode
export LESS_TERMCAP_us=$'\E[04;35m'     # start underline-mode (underline magenta)
export LESS_TERMCAP_ue=$'\E[0m'         # end underline-mode
export LESS_TERMCAP_me=$'\E[0m'         # end modes
