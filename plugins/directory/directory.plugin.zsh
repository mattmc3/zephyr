###
# directory - Set directory options and define directory aliases.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

#
# Options
#

# Directory options
setopt AUTO_PUSHD            # cd automatically uses the dirstack.
setopt CDABLE_VARS           # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB         # Use extended globbing syntax.
setopt MULTIOS               # Write to multiple descriptors.
setopt PUSHD_MINUS           # Swap meanings of +/- to be more natural.
setopt PUSHD_SILENT          # Do not print the dirstack after pushd/popd.
setopt PUSHD_TO_HOME         # pushd with no args goes to home.

#
# Aliases
#

alias -- -='cd -'
alias dirh='dirs -v'
for _idx ({1..9}) alias "$_idx"="cd -${_idx}"

# setup 'cd ..2' aliases
typeset -a _dotdot=('..')
for _idx ({1..9}); do
  alias -g ..${_idx}="${(j:/:)_dotdot}"
  _dotdot+=('..')
done
unset _idx _dotdot
