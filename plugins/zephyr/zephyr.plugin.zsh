###
# zephyr - Zephyr setup helper
###

#
# Requirements
#

if zstyle -t ':zephyr:core' initialized; then
  return
fi

#
# Variables
#

ZEPHYR_HOME=${ZEPHYR_HOME:-${0:A:h:h:h}}

# Load zstyles from .zstyles if file found.
[[ -f ${ZDOTDIR:-$HOME}/.zstyles ]] && . ${ZDOTDIR:-$HOME}/.zstyles

#
# Init
#

# Autoload functions.
fpath=(${0:A:h}/functions $fpath)
autoload -U $fpath[1]/*(.:t)

# Clone external deps.
_repos=(
  romkatv/zsh-bench
  romkatv/zsh-defer
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-syntax-highlighting
)
zephyr-clone $_repos

# Tell plugins that Zephyr has been initialized.
zstyle ':zephyr:core' initialized 'yes'

#
# Cleanup
#

unset _repos