#
# conf.d - Use a Fish-like conf.d directory for sourcing configs.
#

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:boostrap' loaded || source ${0:a:h:h:h}/lib/boostrap.zsh

# Find the conf.d directory.
zstyle -a ':zephyr:plugin:confd' directory '_confd' ||
  _confd=(
    $__zsh_config_dir/conf.d(N)
    $__zsh_config_dir/zshrc.d(N)
    $__zsh_config_dir/rc.d(N)
    ${ZDOTDIR:-$HOME}/.zshrc.d(N)
  )
(( $#_confd )) || return 1

# Source all scripts in conf.d.
for _rcfile in $_confd[1]/*.{z,}sh(N); do
  # ignore files that begin with ~
  [[ ${_rcfile:t} == '~'* ]] && continue
  source $_rcfile
done

# Clean up.
unset _rcfile _confd

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:confd' loaded 'yes'
