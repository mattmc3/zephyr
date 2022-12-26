###
# Zephyr initialization.
###

0=${(%):-%x}
ZEPHYR_HOME="${ZEPHYR_HOME:-$0:A:h:h}"

# Load zephyr functions
fpath+="$ZEPHYR_HOME/functions"
autoload -Uz autoload-dir
autoload-dir "$ZEPHYR_HOME/functions"

# clone Zephyr requirements
zephyr-clone \
  belak/zsh-utils \
  sindresorhus/pure \
  ohmyzsh/ohmyzsh \
  romkatv/zsh-defer \
  romkatv/zsh-bench \
  romkatv/powerlevel10k \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions \
  zsh-users/zsh-history-substring-search \
  zsh-users/zsh-syntax-highlighting \
  zdharma-continuum/fast-syntax-highlighting \
  rupa/z

() {
  # https://www.oliverspryn.com/blog/adding-git-completion-to-zsh
  local gitdir=$ZEPHYR_HOME/.external/git
  if (( ${+commands[curl]} )) && [[ ! -d $gitdir ]]; then
    mkdir -p $gitdir

    # Download the latest git completion scripts
    curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $gitdir/git-completion.bash
    curl -fsSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh -o $gitdir/_git
  fi
}

# Load pre-reqs.
source $ZEPHYR_HOME/.external/zsh-defer/zsh-defer.plugin.zsh

# Update weekly.
zephyr-updatecheck

# tell plugins that Zephyr has been initialized
zstyle ':zephyr:core' initialized 'yes'
