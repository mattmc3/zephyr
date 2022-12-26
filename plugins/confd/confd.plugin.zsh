_zcfghome=${ZDOTDIR:-${XDG_CONFIG_HOME:-HOME/.config}/zsh}
_confd=(
  $_zcfghome/zshrc.d(N/)
  $_zcfghome/conf.d(N/)
  $_zcfghome/rc.d(N/)
  ${ZDOTDIR:-$HOME}/.zshrc.d(N/)
)
(( $#_confd )) || return
for _f in $_confd[1]/*.zsh(N); do
  # ignore files that begin with ~
  case ${_f:t} in '~'*) continue;; esac
  source "$_f"
done
unset _f _confd _zcfghome
