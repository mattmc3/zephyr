###
# conf.d - Use a Fish-like conf.d directory for sourcing configs.
###

#
# Init
#

_zhome=${ZDOTDIR:-${XDG_CONFIG_HOME:=HOME/.config}/zsh}
_confd=(
  $_zhome/zshrc.d(N/)
  $_zhome/conf.d(N/)
  $_zhome/rc.d(N/)
  ${ZDOTDIR:-$HOME}/.zshrc.d(N/)
)
(( $#_confd )) || return
for _rcfile in $_confd[1]/*.{z,}sh(N); do
  # ignore files that begin with ~
  case ${_rcfile:t} in '~'*) continue;; esac
  source "$_rcfile"
done

#
# Cleanup
#

unset _rcfile _confd _zhome
