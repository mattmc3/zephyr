#
# directory - Set directory options and define directory aliases.
#

#
# Requirements
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%N}

#
# External
#

source ${0:A:h}/external/prezto_directory.zsh

#
# Options
#

# 16.2.1 Changing Directories
setopt pushd_minus             # Exchanges meanings of +/- when navigating the dirstack.

# 16.2.3 Expansion and Globbing
setopt glob_dots               # Don't hide dotfiles from glob patterns.

#
# Aliases
#

if ! zstyle -t ':zephyr:plugin:directory:alias' skip; then
  # directory aliases
  unalias d 2>/dev/null
  alias dirh='dirs -v'

  for index in {1..9}; do
    # backref aliases (eg: "..3"="../../..")
    alias -g "..$index"=$(printf '../%.0s' {1..$index})
  done
  unset index
fi

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:directory' loaded 'yes'
