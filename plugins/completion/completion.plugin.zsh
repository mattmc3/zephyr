#
# completion - Set up zsh completions.
#
# THIS FILE IS GENERATED:
# - https://github.com/belak/zsh-utils/blob/main/completion/completion.plugin.zsh
#

#
# Requirements
#

if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

if zstyle -T ':zephyr:plugins:completion' use-xdg-basedirs; then
  # Ensure the cache directory exists.
  _cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
  [[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"

  _zcompdump="$_cache_dir/compdump"
  _zcompcache="$_cache_dir/compcache"
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
unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.
unsetopt CASE_GLOB         # Case-insensitive globbing.

#
# fpath
#

fpath=(${0:A:h}/functions $fpath)
autoload -z $fpath[1]/*(.:t)

fpath=(
  # Add curl completions from homebrew.
  /{usr/local,opt/homebrew}/opt/curl/share/zsh/site-functions(-/FN)

  # Add zsh completions.
  /{usr/local,opt/homebrew}/share/zsh/site-functions(-/FN)

  # Add custom completions.
  ${ZDOTDIR:-${XDG_CONFIG_HOME:-~/.config}/zsh}/completions(-/FN)

  # rest of fpath
  $fpath
)

#
# Styles
#

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$_zcompcache"

#
# Init
#

# Initialize completion styles. Users can set their preferred completion style by
# calling `compstyle <compstyle>` in their .zshrc, or by defining their own
# `compstyle_<name>_setup` functions similar to the zsh prompt system.
fpath+="${0:A:h}/functions"
autoload -Uz compstyleinit && compstyleinit
zstyle -s ':zephyr:plugin:completion' compstyle '_compstyle' || _compstyle='zephyr'
compstyle $_compstyle
unset _compstyle

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

#
# Misc
#

# Compile compdump, if modified, in background to increase startup speed.
(
  if [[ -s "$_zcompdump" && (! -s "${_zcompdump}.zwc" || "$_zcompdump" -nt "${_zcompdump}.zwc") ]]; then
    zcompile "$_zcompdump"
  fi
) &!

#
# Cleanup
#

unset _cache_dir _comp_files _zcompdump _zcompcache

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:completion' loaded 'yes'
