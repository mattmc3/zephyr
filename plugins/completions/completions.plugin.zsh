#
# Requirements
#

0=${(%):-%x}
if ! (( $+functions[zephyrinit] )); then
  autoload -Uz ${0:A:h:h:h}/functions/zephyrinit && zephyrinit
fi

#
# Init
#

# if homebrew completions exist, use those
if (( $+commands[brew] )); then
  brew_prefix=${commands[brew]:A:h:h}
  fpath=("$brew_prefix"/share/zsh/site-functions(-/FN) $fpath)
  fpath=("$brew_prefix"/opt/curl/share/zsh/site-functions(-/FN) $fpath)
  unset brew_prefix
fi

fpath+=$ZEPHYR_HOME/.external/zsh-completions/src
source $ZEPHYR_HOME/.external/zsh-utils/completion/completion.plugin.zsh

zstyle -s ':zephyr:plugins:completion' compstyle \
  '_compstyle' || _compstyle=zshzoo
compstyle $_compstyle
unset _compstyle
