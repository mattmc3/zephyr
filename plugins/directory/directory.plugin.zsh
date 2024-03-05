#
# directory - Set directory options and define directory aliases.
#

# References:
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/directory
# - https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

# 16.2.3 Expansion and Globbing
setopt extended_glob           # Use more awesome globbing features.
setopt glob_dots               # Include dotfiles when globbing.

# 16.2.1 Changing Directories
setopt auto_pushd              # Make cd push the old directory onto the dirstack.
setopt pushd_minus             # Exchanges meanings of +/- when navigating the dirstack.
setopt pushd_silent            # Do not print the directory stack after pushd or popd.
setopt pushd_to_home           # Push to home directory when no argument is given.

# 16.2.6 Input/Output
setopt NO_clobber              # Don't overwrite files with >. Use >| to bypass.
setopt NO_rm_star_silent       # Ask for confirmation for `rm *' or `rm path/*'

# 16.2.9 Scripts and Functions
setopt multios                 # Write to multiple descriptors.

# Set directory aliases.
if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  alias -- -='cd -'
  alias dirh='dirs -v'
  () {
    local i dotdot=('..')
    for i in {1..9}; do
      alias "$i"="cd -${i}"             # dirstack aliases (eg: "3"="cd -3")
      alias -g "..$i"=${(pj:/:)dotdot}  # backref aliases (eg: "..3"="../../..")
      dotdot+=('..')
    done
  }
fi

if ! zstyle -t ':zephyr:plugin:directory:function' skip; then
  ##? up: Quickly go up any number of directories.
  function up {
    local parents=${1:-1}
    if ! [[ "$parents" -gt 0 ]]; then
      echo >&2 "up: expecting numeric argument: number of parent dirs"
      return 1
    fi
    local -a dotdots=($(printf "..%.0s\n" {1..$parents}))
    local cdstr="${(pj:/:)dotdots}"
    cd $cdstr
  }
fi

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:directory' loaded 'yes'
