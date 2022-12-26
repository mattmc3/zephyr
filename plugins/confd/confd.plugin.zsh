###
# conf.d - Use a Fish-like conf.d directory for sourcing configs.
###

#
# Init
#

_zcfghome=${ZDOTDIR:-${XDG_CONFIG_HOME:=HOME/.config}/zsh}
_confd=(
  $_zcfghome/zshrc.d(N/)
  $_zcfghome/conf.d(N/)
  $_zcfghome/rc.d(N/)
  ${ZDOTDIR:-$HOME}/.zshrc.d(N/)
)
(( $#_confd )) || return
for _rcfile in $_confd[1]/*.{z,}sh(N); do
  # ignore files that begin with ~
  case ${_rcfile:t} in '~'*) continue;; esac
  source "$_rcfile"
done
unset _rcfile _confd _zcfghome
