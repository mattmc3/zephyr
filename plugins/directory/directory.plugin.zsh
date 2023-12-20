#
# directory - Set directory options and define directory aliases.
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# Set Zsh options related to directories, globbing, and I/O.
setopt auto_pushd         # Make cd push the old directory onto the dirstack.
setopt pushd_ignore_dups  # Don’t push multiple copies of the same directory onto the dirstack.
setopt pushd_minus        # Exchanges meanings of +/- when navigating the dirstack.
setopt pushd_silent       # Do not print the directory stack after pushd or popd.
setopt pushd_to_home      # Push to home directory when no argument is given.
setopt extended_glob      # Use extended globbing syntax.
setopt glob_dots          # Don't hide dotfiles from glob patterns.
setopt multios            # Write to multiple descriptors.
setopt NO_clobber         # Don't overwrite files with >. Use >| to bypass.

# Set aliases.
if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  # directory aliases
  alias -- -='cd -'
  alias dirh='dirs -v'

  for index in {1..9}; do
    # dirstack aliases (eg: "2"="cd 2")
    alias "$index"="cd +${index}"
    # backref aliases (eg: "..3"="../../..")
    alias -g "..$index"=$(printf '../%.0s' {1..$index})
  done
  unset index
fi

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:directory' loaded 'yes'
