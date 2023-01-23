###
# directory - Set directory options and define directory aliases.
###

#
# Options
#

setopt AUTO_CD              # Auto changes to a directory without typing cd.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt PUSHD_MINUS          # Swap meanings of +/- to be more natural.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass.

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
