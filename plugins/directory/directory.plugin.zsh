###
# directory - Set directory options and define directory aliases.
###

#
# Options
#

setopt AUTO_PUSHD                # Make cd push the old dir onto the dirstack.
setopt PUSHD_IGNORE_DUPS         # Don’t push multiple copies of a dir to the dirstack.
setopt PUSHD_SILENT              # Do not print the dirstack after pushd or popd.
setopt PUSHD_MINUS               # Exchange meanings of +/- when navigating the dirstack.
setopt PUSHD_TO_HOME             # Push to home directory when no argument is given.
setopt CDABLE_VARS               # Change directory to a path stored in a variable.
setopt MULTIOS                   # Write to multiple descriptors.
setopt EXTENDED_GLOB             # Use extended globbing syntax.
setopt NO_CLOBBER                # Do not overwrite files with >. Use >| to bypass.

#
# Aliases
#

if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  alias -- -='cd -'
  alias dirh='dirs -v'
  dotdot=".."
  for index ({1..9}); do
    alias "$index"="cd +${index}"
    alias -g "..$index"="$dotdot"
    dotdot+='/..'
  done
  unset index dotdot
fi

#
# Wrap up
#

zstyle ":zephyr:plugin:directory" loaded 'yes'
