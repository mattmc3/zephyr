#
# terminal - Sets terminal window and tab titles.
#

#
# Requirements
#

# Return if requirements are not found.
if [[ "$TERM" == (dumb|linux|*bsd*|eterm*) ]]; then
  return 1
fi

#
# Init
#

# Use Prezto's terminal module.
source ${0:a:h}/external/prezto_terminal.zsh

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:terminal' loaded 'yes'
