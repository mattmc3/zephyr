#
# directory - Set directory options and define directory aliases.
#

() {
  #
  # Options
  #

  local diropts=(
    # 16.2.1 Changing Directories
    auto_cd                 # If a command isn't valid, but is a directory, cd to that dir.
    auto_pushd              # Make cd push the old directory onto the dirstack.
    cdable_vars             # Change directory to a path stored in a variable.
    pushd_ignore_dups       # Don’t push multiple copies of the same directory onto the dirstack.
    pushd_minus             # Exchanges meanings of +/- when navigating the dirstack.
    pushd_silent            # Do not print the directory stack after pushd or popd.
    pushd_to_home           # Push to home directory when no argument is given.

    # 16.2.3 Expansion and Globbing
    extended_glob           # Use extended globbing syntax.
    glob_dots               # Don't hide dotfiles from glob patterns.

    # 16.2.6 Input/Output
    NO_clobber              # Don't overwrite files with >. Use >| to bypass.

    # 16.2.9 Scripts and Functions
    multios                 # Write to multiple descriptors.
  )
  setopt $diropts

  #
  # Aliases
  #

  if ! zstyle -t ':zephyr:directory:alias' skip; then
    alias -- -='cd -'
    alias dirh='dirs -v'

    local dotdots=".."
    for index in {1..9}; do
      # dirstack aliases (eg: "2"="cd 2")
      alias "$index"="cd +${index}"
      # backref aliases (eg: "..3"="../../..")
      alias -g "..$index"="$dotdots"
      dotdots+='/..'
    done
  fi

  #
  # Wrap up
  #

  # Tell Zephyr this plugin is loaded.
  zstyle ':zephyr:plugin:directory' loaded 'yes'
}
