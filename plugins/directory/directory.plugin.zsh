#
# directory - Set directory options and define directory aliases.
#

# References:
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/directory

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# Set Zsh options related to directories, globbing, and I/O.
setopt auto_pushd           # Make cd push the old directory onto the dirstack.
setopt pushd_ignore_dups    # Don’t push multiple copies of the same directory onto the dirstack.
setopt pushd_minus          # Exchanges meanings of +/- when navigating the dirstack.
setopt pushd_silent         # Do not print the directory stack after pushd or popd.
setopt pushd_to_home        # Push to home directory when no argument is given.
setopt multios              # Write to multiple descriptors.
setopt extended_glob        # Use extended globbing syntax.
setopt glob_dots            # Don't hide dotfiles from glob patterns.
setopt NO_clobber           # Don't overwrite files with >. Use >| to bypass.
setopt NO_rm_star_silent    # Ask for confirmation for `rm *' or `rm path/*'

# Set aliases.
if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  # directory aliases
  alias -- -='cd -'
  alias dirh='dirs -v'

  () {
    local i
    local -a dotdot=('..')
    for i in {1..9}; do
      # dirstack aliases (eg: "2"="cd 2")
      alias "$i"="cd -${i}"
      # backref aliases (eg: "..3"="../../..")
      alias -g "..$i"=${(pj;/;)dotdot}
      dotdot+=('..')
    done
  }
fi

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:directory' loaded 'yes'
