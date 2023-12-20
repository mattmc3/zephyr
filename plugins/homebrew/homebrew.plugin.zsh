#
# homebrew - Environment variables and functions for homebrew users.
#

# References:
# - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/homebrew

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:boostrap' loaded || source ${0:a:h:h:h}/lib/boostrap.zsh
-zephyr-autoload-dir ${0:a:h}/functions

# Where is brew?
typeset -aU brewcmd=(
  $HOME/brew/bin/brew(N)
  $commands[brew]
  /opt/homebrew/bin/brew(N)
  /usr/local/bin/brew(N)
)
(( $#brewcmd )) || return 1

# Default to no tracking.
HOMEBREW_NO_ANALYTICS=${HOMEBREW_NO_ANALYTICS:-1}

# Set aliases.
if ! zstyle -t ':zephyr:plugin:homebrew:alias' skip; then
  alias brewup="brew update && brew upgrade && brew cleanup"
  alias brewinfo="brew leaves | xargs brew desc --eval-all"
fi

# Generate a new cache file daily of just the 'HOMEBREW_' vars.
typeset _brew_shellenv=$__zephyr_cache_dir/brew_shellenv.zsh
typeset _brew_shellenv_exclpaths=$__zephyr_cache_dir/brew_shellenv_exclpaths.zsh
typeset -a _brew_cache=($brew_shellenv(Nmh-20))
if ! (( $#_brew_cache )); then
  brew shellenv 2> /dev/null >| $_brew_shellenv
  grep "export HOMEBREW_" $_brew_shellenv >| $_brew_shellenv_exclpaths
fi

# Allow a user to do their own shellenv setup.
if ! zstyle -t ':zephyr:plugin:homebrew:shellenv' skip; then
  if zstyle -t ':zephyr:plugin:homebrew:shellenv' 'include-paths'; then
    source $_brew_shellenv
  else
    source $_brew_shellenv_exclpaths
  fi
fi

# Clean up.
unset _brew_{cache,shellenv,shellenv_exclpaths}

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:homebrew" loaded 'yes'
