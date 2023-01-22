0=${(%):-%N}

# if Zephyr is being loaded as a plugin, and a .zstyles file is not found, then there's
# a chance the user didn't configure the list plugins. If that's the case then let's
# setup a reasonable default list.
if [[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]]; then
  # get list of plugins from zstyle
  zstyle -a ':zephyr:load' plugins '_zephyr_plugins'

  # if nothing provided, set a default list
  (( $#_zephyr_plugins )) ||
    zstyle ':zephyr:load' plugins \
      color \
      environment \
      editor \
      history \
      directory \
      utility \
      prompt \
      completion
fi

source ${0:A:h}/zephyr.zsh
