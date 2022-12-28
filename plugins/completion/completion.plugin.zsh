####
# completion - Set up zsh completions.
###

#
# Requirements
#

zstyle -t ':zephyr:core' initialized || return 1
[[ "$TERM" != 'dumb' ]] || return 1

if zstyle -T ':zephyr:plugins:completion' use-xdg-basedirs; then
  # Ensure the cache directory exists.
  [[ -d "${XDG_CACHE_HOME:=$HOME/.cache}/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

  _zcompdump="$XDG_CACHE_HOME/zsh/compdump"
  _zcompcache="$XDG_CACHE_HOME/zsh/compcache"
else
  _zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  _zcompcache="${ZDOTDIR:-$HOME}/.zcompcache"
fi

#
# Options
#

setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
setopt AUTO_MENU           # Show completion menu on a successive tab press.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.
setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit
setopt NO_CASE_GLOB        # Case-insensitive globbing.
setopt NO_MENU_COMPLETE    # Do not autoselect the first completion entry.
setopt NO_FLOW_CONTROL     # Disable start/stop characters in shell editor.

#
# Styles
#

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$_zcompcache"
zstyle ':completion:*:*:git:*' script $ZEPHYR_HOME/.external/git/git-completion.bash

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

# Initialize completion styles. Users can set their preferred completion style by
# calling `compstyle <compstyle>` in their .zshrc, or by defining their own
# `compstyle_<name>_setup` functions similar to the zsh prompt system.
autoload -Uz compstyle

# Load and initialize the completion system ignoring insecure directories with a
# cache time of 20 hours, so it should almost always regenerate the first time a
# shell is opened each day.
autoload -Uz compinit
_comp_files=($_zcompdump(Nmh-20))
if (( $#_comp_files )); then
  compinit -i -C -d "$_zcompdump"
else
  compinit -i -d "$_zcompdump"
  # Keep $_zcompdump younger than cache time even if it isn't regenerated.
  touch "$_zcompdump"
fi

# Compile compdump, if modified, in background to increase startup speed.
{
  if [[ -s "$_zcompdump" && (! -s "${_zcompdump}.zwc" || "$_zcompdump" -nt "${_zcompdump}.zwc") ]]; then
    zcompile "$_zcompdump"
  fi
} &!

#
# Cleanup
#

unset _cache_dir _comp_files _zcompdump _zcompcache
