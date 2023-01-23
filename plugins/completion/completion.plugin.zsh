####
# completion - Set up zsh completions.
###

#
# Requirements
#

[[ "$TERM" != 'dumb' ]] || return 1

if ! zstyle -t ':zephyr:core' initialized; then
  source ${0:A:h:h}/zephyr/zephyr.plugin.zsh
fi

# Ensure the cache directory exists.
[[ -d "${XDG_CACHE_HOME:=$HOME/.cache}/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/compdump"

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
# Init
#

fpath=(${0:A:h}/functions $fpath)
autoload -z $fpath[1]/*(.:t)

fpath=(
  # add git completions if they exist
  ${0:A:h}/external/git(/N)

  # add curl completions from homebrew if they exist
  /{usr,opt}/{local,homebrew}/opt/curl/share/zsh/site-functions(-/FN)

  # add zsh completions
  /{usr,opt}/{local,homebrew}/share/zsh/site-functions(-/FN)

  # add zsh-users completions if they exist
  ${0:A:h:h}/.external/zsh-completion/src(-/FN)

  # Allow user completions.
  ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/completions(-/FN)

  # rest of fpath
  $fpath
)

# Initialize completions.
run-compinit

#
# Styles
#

# Initialize completion styles. Users can set their preferred completion style by
# calling `compstyle <compstyle>` in their .zshrc, or by defining their own
# `compstyle_<name>_setup` functions similar to the zsh prompt system.
zstyle -s ':zephyr:plugin:completion' compstyle '_compstyle' ||
  _compstyle='zephyr'
_compstyle_fn="compstyle_${_compstyle}_setup"

(( $+functions[$_compstyle_fn] )) && $_compstyle_fn || return 1

#
# Cleanup
#

unset _compstyle{,_fn}
