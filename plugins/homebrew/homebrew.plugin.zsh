#
# Homebrew: Environment variables and functions for homebrew users.
#

# References:
# - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/homebrew

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

#region zephyr_plugin_homebrew
# Where is brew?
typeset -aU brewcmd=(
  $HOME/brew/bin/brew(N)
  $commands[brew]
  /opt/homebrew/bin/brew(N)
  /usr/local/bin/brew(N)
  /home/linuxbrew/.linuxbrew/bin/brew(N)
  $HOME/.linuxbrew/bin/brew(N)
)
(( $#brewcmd )) || return 1

# Cache 'brew shellenv'.
cached-command 'brew-shellenv' ${brewcmd[1]} shellenv

# Default to no tracking.
HOMEBREW_NO_ANALYTICS=${HOMEBREW_NO_ANALYTICS:-1}

# Set aliases.
if ! zstyle -t ':zephyr:plugin:homebrew:alias' skip; then
  alias brewup="brew update && brew upgrade && brew cleanup"
  alias brewinfo="brew leaves | xargs brew desc --eval-all"
fi

if ! zstyle -t ':zephyr:plugin:homebrew:function' skip; then
  ##? Show brewed apps.
  function brews {
    local formulae="$(brew leaves | xargs brew deps --installed --for-each)"
    local casks="$(brew list --cask 2>/dev/null)"

    local blue="$(tput setaf 4)"
    local bold="$(tput bold)"
    local off="$(tput sgr0)"

    echo "${blue}==>${off} ${bold}Formulae${off}"
    echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
    echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
  }
fi

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:homebrew' loaded 'yes'
#endregion
