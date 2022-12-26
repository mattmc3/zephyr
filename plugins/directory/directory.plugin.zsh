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

alias dirh='dirs -v'
() {
  # setup `cd ..2` aliases
  local idx
  local -a dotdot=('..')
  for idx ({2..9}); do
    dotdot+=('..')
    alias -g ..${idx}="${(j./.)dotdot}"
  done
}
