#
# Source files in a conf.d directory, similar to Fish
#

confd=${ZDOTDIR:-$HOME/.config/zsh}/conf.d
if [[ ! -d $confd ]]; then
  confd=${ZDOTDIR:-$HOME/.config/zsh}/zshrc.d
fi
for f in $confd/*.zsh(N); do
  # ignore files that begin with a tilde
  case ${f:t} in '~'*) continue;; esac
  source "$f"
done
unset f confd
