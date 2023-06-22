#
# completion - Set up zsh completions.
#

#
# References
#

# https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh#L31-L44
# https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin#L9-L15
# http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit
# https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2894219
# https://htr3n.github.io/2018/07/faster-zsh/

#
# Requirements
#

# Return if requirements are not found.
[[ "$TERM" != 'dumb' ]] || return 1

#
# Functions
#

# Autoload plugin functions.
0=${(%):-%N}
fpath=(${0:A:h}/functions $fpath)
autoload -Uz ${0:A:h}/functions/*(.:t)

#
# Options
#

setopt complete_in_word     # Complete from both ends of a word.
setopt always_to_end        # Move cursor to the end of a completed word.
setopt auto_menu            # Show completion menu on a successive tab press.
setopt auto_list            # Automatically list choices on ambiguous completion.
setopt auto_param_slash     # If completed parameter is a directory, add a trailing slash.
setopt extended_glob        # Needed for file modification glob modifiers with compinit.
setopt NO_menu_complete     # Do not autoselect the first completion entry.
setopt NO_flow_control      # Disable start/stop characters in shell editor.

#
# Variables
#

fpath=(
  # Add curl completions from homebrew.
  /{usr/local,opt/homebrew}/opt/curl/share/zsh/site-functions(-/FN)

  # Add zsh completions.
  /{usr/local,opt/homebrew}/share/zsh/site-functions(-/FN)

  # Add custom completions.
  ${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/completions(-/FN)

  # rest of fpath
  $fpath
)

#
# Init
#

# compinit
if ! zstyle -t ':zephyr:plugin:completion' manual; then
  run-compinit
fi

# compstyle
zstyle -s ':zephyr:plugin:completion' compstyle 'zcompstyle' || zcompstyle=zephyr
if (( $+functions[compstyle_${zcompstyle}_setup] )); then
  compstyle_${zcompstyle}_setup
fi
unset zcompstyle

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ':zephyr:plugin:completion' loaded 'yes'
