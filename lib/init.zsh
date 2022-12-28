###
# Zephyr initialization.
###

ZEPHYR_HOME="${0:A:h:h}"

# Load zephyr functions
fpath+="$ZEPHYR_HOME/functions"
autoload -Uz autoload-dir
autoload-dir "$ZEPHYR_HOME/functions"

# clone Zephyr requirements
repos=(
  belak/zsh-utils
  sindresorhus/pure
  ohmyzsh/ohmyzsh
  romkatv/zsh-defer
  romkatv/zsh-bench
  romkatv/powerlevel10k
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-syntax-highlighting
  zdharma-continuum/fast-syntax-highlighting
  rupa/z
)
zephyr-clone $repos
unset repos

# https://www.oliverspryn.com/blog/adding-git-completion-to-zsh
_gitdir=$ZEPHYR_HOME/.external/git
if (( ${+commands[curl]} )) && [[ ! -d $_gitdir ]]; then
  mkdir -p $_gitdir

  # Download the latest git completion scripts
  curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $_gitdir/git-completion.bash
  curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh -o $_gitdir/_git
fi
unset _gitdir

# Load pre-reqs.
if (( ! $+functions[zsh-defer] )); then
  function zsh-defer {
    source $ZEPHYR_HOME/.external/zsh-defer/zsh-defer.plugin.zsh
    zsh-defer "$@"
  }
fi

# Update weekly.
zephyr-updatecheck

# tell plugins that Zephyr has been initialized
zstyle ':zephyr:core' initialized 'yes'
