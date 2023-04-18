#
# directory - Set directory options and define directory aliases.
#
# THIS FILE IS GENERATED:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh
#

#
# Options
#

setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_MINUS          # Exchange meanings of +/- when navigating the dirstack.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite files with >. Use >| to bypass.

#
# Aliases
#

if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  alias -- -='cd -'
  alias dirh='dirs -v'
  for index ({1..9}) alias "$index"="cd +${index}"; unset index
  for dotdot ({1..9}) alias -g "..$dotdot"=$(printf '../%.0s' {1..$dotdot}); unset dotdot
fi

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:directory' loaded 'yes'
