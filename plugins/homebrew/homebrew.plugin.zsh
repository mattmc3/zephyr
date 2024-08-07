#
# homebrew: Environment variables and functions for homebrew users.
#

# References:
# - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/brew
# - https://github.com/sorin-ionescu/prezto/tree/master/modules/homebrew

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh

# Where is brew?
# Setup homebrew if it exists on the system.
typeset -aU _brewcmd=(
  $commands[brew]
  $HOME/.homebrew/bin/brew(N)
  $HOME/.linuxbrew/bin/brew(N)
  /opt/homebrew/bin/brew(N)
  /usr/local/bin/brew(N)
  /home/linuxbrew/.linuxbrew/bin/brew(N)
)
(( ${#_brewcmd} )) || return 1

# brew shellenv
if zstyle -t ':zephyr:plugin:homebrew' 'use-cache'; then
  cached-eval 'brew_shellenv' $_brewcmd[1] shellenv
else
  source <($_brewcmd[1] shellenv)
fi
unset _brewcmd

# Ensure user bins preceed homebrew in path.
path=($prepath $path)

# Default to no tracking.
HOMEBREW_NO_ANALYTICS=${HOMEBREW_NO_ANALYTICS:-1}

# Add brewed Zsh to fpath
if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")
fi

# Add keg-only completions to fpath
zstyle -a ':zephyr:plugin:homebrew' 'keg-only-brews' '_kegonly' \
  || _kegonly=(curl ruby sqlite)
for _keg in $_kegonly; do
  fpath=($HOMEBREW_PREFIX/opt/${_keg}/share/zsh/site-functions(/N) $fpath)
done
unset _keg{,only}

# Set aliases.
if ! zstyle -t ':zephyr:plugin:homebrew:alias' skip; then
  alias brewup="brew update && brew upgrade && brew cleanup"
  alias brewinfo="brew leaves | xargs brew desc --eval-all"
  alias brewdeps='brew leaves | xargs brew deps --installed --for-each | awk ''{leaf=$1;$1=""; printf "%s\033[34m%s\033[0m\n",leaf,$0}'''

  # Handle brew on multi-user systems.
  _brew_owner="$(stat -f "%Su" "$HOMEBREW_PREFIX" 2>/dev/null)"
  if [[ -n "$_brew_owner" ]] && [[ "$(whoami)" != "$_brew_owner" ]]; then
    alias brew="sudo -Hu '$_brew_owner' brew"
  fi
  unset _brew_owner
fi

# Mark this plugin as loaded.
zstyle ':zephyr:plugin:homebrew' loaded 'yes'
