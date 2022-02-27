#
# source conf.d like fish does
#

confd=${ZDOTDIR:-$HOME/.config/zsh}/conf.d
if [[ ! -d $confd ]]; then
  confd=${ZDOTDIR:-$HOME/.config/zsh}/zshrc.d
fi
for f in $confd/*.zsh(N); do
  source "$f"
done
unset f confd
