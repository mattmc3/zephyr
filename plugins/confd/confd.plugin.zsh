##? conf.d - Use a Fish-like conf.d directory for sourcing configs.

# Try to detect conf.d.
_zhome=${ZDOTDIR:-${XDG_CONFIG_HOME:=HOME/.config}/zsh}
_confd=(
  $_zhome/zshrc.d(N)
  $_zhome/conf.d(N)
  $_zhome/rc.d(N)
  ${ZDOTDIR:-$HOME}/.zshrc.d(N)
)
(( $#_confd )) || return 1

# Source all files in conf.d.
for _rcfile in $_confd[1]/*.{z,}sh(N); do
  # ignore files that begin with ~
  case ${_rcfile:t} in '~'*) continue;; esac
  source "$_rcfile"
done
unset _rcfile _confd _zhome

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:confd" loaded 'yes'
