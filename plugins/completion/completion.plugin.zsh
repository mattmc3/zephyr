#
# completion - Set up zsh completions.
#
# THIS FILE IS GENERATED:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh
#

#
# Requirements
#

# Return if requirements are not found.
if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

# Autoload plugin functions.
fpath=(${0:A:h}/functions $fpath)
autoload -z $fpath[1]/*(.:t)

# Ensure the cache directory exists.
_cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zephyr
[[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"
unset _cache_dir

#
# Options
#

setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
setopt ALWAYS_TO_END        # Move cursor to the end of a completed word.
setopt AUTO_MENU            # Show completion menu on a successive tab press.
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH     # If completed parameter is a directory, add a trailing slash.
setopt EXTENDED_GLOB        # Needed for file modification glob modifiers with compinit.
unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL       # Disable start/stop characters in shell editor.

#
# Variables
#

# Standard style used by default for 'list-colors'
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}

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
# Init
#

# Load and initialize the completion system ignoring insecure directories with a
# cache time of 20 hours, so it should almost always regenerate the first time a
# shell is opened each day.
autoload -Uz compinit
_comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zephyr/zcompdump"
# #q expands globs in conditional expressions
if [[ $_comp_path(#qNmh-20) ]]; then
  # -C (skip function check) implies -i (skip security check).
  compinit -C -d "$_comp_path"
else
  mkdir -p "$_comp_path:h"
  compinit -i -d "$_comp_path"
  # Keep $_comp_path younger than cache time even if it isn't regenerated.
  touch "$_comp_path"
fi

#
# Misc
#

# Compile compdump, if modified, in background to increase startup speed.
(
  if [[ -s "$_comp_path" && (! -s "${_comp_path}.zwc" || "$_comp_path" -nt "${_comp_path}.zwc") ]]; then
    zcompile "$_comp_path"
  fi
) &!

# Clean up
unset _comp_path

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:completion' loaded 'yes'
