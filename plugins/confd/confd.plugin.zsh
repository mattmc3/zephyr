#
# conf.d - Use a Fish-like conf.d directory for sourcing configs.
#

#
# Variables
#

: ${__zsh_config_dir:=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}

zstyle -a ':zephyr:plugin:confd' directory '_confd' ||
  _confd=(
    $__zsh_config_dir/conf.d(N)
    $__zsh_config_dir/zshrc.d(N)
    $__zsh_config_dir/rc.d(N)
    ${ZDOTDIR:-$HOME}/.zshrc.d(N)
  )
(( $#_confd )) || return 1

#
# Init
#

# Source all files in conf.d.
for _rcfile in $_confd[1]/*.{z,}sh(N); do
  # ignore files that begin with ~
  [[ ${_rcfile:t} == '~'* ]] && continue
  source $_rcfile
done

#
# Clean up
#

unset _rcfile _confd

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:confd' loaded 'yes'
