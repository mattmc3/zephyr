####
# completion - Set up zsh completions.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1
0=${(%):-%x}
: ${ZEPHYR_HOME:=${0:A:h:h:h}}
zstyle -t ':zephyr:core' initialized || . $ZEPHYR_HOME/lib/init.zsh

#
# Init
#

fpath=(
  # add git completions if they exist
  $ZEPHYR_HOME/.external/git(/N)

  # add curl completions from homebrew if they exist
  /{usr,opt}/{local,homebrew}/opt/curl/share/zsh/site-functions(-/FN)

  # add zsh completions
  /{usr,opt}/{local,homebrew}/share/zsh/site-functions(-/FN)

  # add zsh-users completions if they exist
  $ZEPHYR_HOME/.external/zsh-completion/src(-/FN)

  # Allow user completions.
  ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/completions(-/FN)

  # this plugin and rest of fpath
  ${0:A:h}/functions
  $fpath
)

# Use zsh-utils completion.
source $ZEPHYR_HOME/.external/zsh-utils/completion/completion.plugin.zsh

# Set additional compstyles
zstyle ':completion:*:*:git:*' script $ZPLUGINDIR/.external/git/git-completion.bash
