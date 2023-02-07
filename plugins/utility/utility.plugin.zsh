###
# utility - Hodgepodge of Zsh shell options and utilities.
###

#
# Options
#

# Glob options.
setopt EXTENDED_GLOB         # Use more awesome globbing features.
setopt GLOB_DOTS             # Include dotfiles when globbing.
setopt NO_RM_STAR_SILENT     # Ask for confirmation for `rm *' or `rm path/*'

# General options.
setopt COMBINING_CHARS       # Combine 0-len chars with the base character (eg: accents).
setopt INTERACTIVE_COMMENTS  # Enable comments in interactive shell.
setopt RC_QUOTES             # Allow 'Hitchhikers''s Guide' instead of 'Hitchhikers'\''s Guide'.
setopt NO_MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.
setopt NO_BEEP               # Don't Beep on error in line editor.

# Job options.
setopt LONG_LIST_JOBS        # List jobs in the long format by default.
setopt AUTO_RESUME           # Attempt to resume existing job before creating a new process.
setopt NOTIFY                # Report status of background jobs immediately.
setopt NO_BG_NICE            # Don't run all background jobs at a lower priority.
setopt NO_HUP                # Don't kill jobs on shell exit.
setopt NO_CHECK_JOBS         # Don't report on jobs when shell exit.


#
# Functions
#

# Autoload functions.
fpath=(${0:A:h}/functions $fpath)
autoload -Uz $fpath[1]/*(.:t)


#
# Commands
#

# Fallback function for missing envsubst command.
if (( ! $+commands[envsubst] )); then
  function envsubst {
    python -c 'import os,sys;[sys.stdout.write(os.path.expandvars(l)) for l in sys.stdin]'
  }
fi

# Fallback aliases for missing pbcopy/pbpaste commands.
if (( ! $+commands[pbcopy] )); then
  if [[ "$OSTYPE" == (cygwin|msys)* ]]; then
    alias pbcopy='tee > /dev/clipboard'
    alias pbpaste='cat /dev/clipboard'
  elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] )); then
    alias pbcopy="clip.exe"
    alias pbpaste="powershell.exe -noprofile -command Get-Clipboard"
  elif [ -n $WAYLAND_DISPLAY ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} )); then
    alias pbcopy="wl-copy"
    alias pbpaste="wl-paste"
  elif [ -n $DISPLAY ] && (( ${+commands[xsel]} )); then
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste="xsel --clipboard --output"
  elif [ -n $DISPLAY ] && (( ${+commands[xclip]} )); then
    alias pbcopy='xclip -selection clipboard -in'
    alias pbpaste='xclip -selection clipboard -out'
  elif (( ${+commands[win32yank]} )); then
    alias pbcopy='win32yank -i'
    alias pbpaste='win32yank -o'
  elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] )); then
    alias pbcopy='termux-clipboard-set'
    alias pbpaste='termux-clipboard-get'
  elif [ -n $TMUX ] && (( ${+commands[tmux]} )); then
    alias pbcopy='tmux load-buffer'
    alias pbpaste='tmux save-buffer'
  fi
fi

# Fallback function for missing open command.
if (( ! $+commands[open] )); then
  if [[ $OSTYPE == cygwin* ]]; then
    alias open='cygstart'
  elif [[ $OSTYPE == msys* ]]; then
    alias open='start ""'
  elif (( $+commands[xdg-open] )); then
    alias open='xdg-open'
  elif [[ $OSTYPE == linux* ]] && [[ "$(uname -r)" == *icrosoft* ]]; then
    alias open='cmd.exe /c start ""'
  fi
fi


#
# Misc
#

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
alias help=run-help


#
# Wrap up
#

zstyle ":zephyr:plugin:utility" loaded 'yes'
