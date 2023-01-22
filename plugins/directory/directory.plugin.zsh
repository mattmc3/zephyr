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

if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  alias -- -='cd -'
  alias dirh='dirs -v'

  # set global backref aliases (eg: "..3"="../../..") and
  # set dirstack aliases (eg: "-4"="cd -4")
  local _dotdots=".."
  for _idx ({1..9}); do
    alias "$_idx"="cd -${_idx}"
    alias -g "..$_idx"="$_dotdots"
    _dotdots+='/..'
  done

  # clean up
  unset _idx _dotdots
fi
