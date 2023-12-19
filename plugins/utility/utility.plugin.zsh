#
# utility - Misc Zsh shell options and utilities.
#

#
# Options
#

# Glob options.
setopt extended_glob         # Use more awesome globbing features.
setopt glob_dots             # Include dotfiles when globbing.
setopt no_rm_star_silent     # Ask for confirmation for `rm *' or `rm path/*'

# General options.
setopt combining_chars       # Combine 0-len chars with the base character (eg: accents).
setopt interactive_comments  # Enable comments in interactive shell.
setopt rc_quotes             # Allow 'Hitchhikers''s Guide' instead of 'Hitchhikers'\''s Guide'.
setopt NO_mail_warning       # Don't print a warning message if a mail file has been accessed.
setopt NO_beep               # Don't Beep on error in line editor.

# Job options.
setopt long_list_jobs        # List jobs in the long format by default.
setopt auto_resume           # Attempt to resume existing job before creating a new process.
setopt notify                # Report status of background jobs immediately.
setopt NO_bg_nice            # Don't run all background jobs at a lower priority.
setopt NO_hup                # Don't kill jobs on shell exit.
setopt NO_check_jobs         # Don't report on jobs when shell exit.

#
# Functions
#

# Load plugin functions.
0=${(%):-%N}
fpath=(${0:a:h}/functions $fpath)
autoload -Uz ${0:a:h}/functions/*(.:t)

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

#
# Aliases
#

# Common utils everywhere.

# Linux-like envsubst command
if ! (( $+commands[envsubst] )); then
  alias envsubst="python -c 'import os,sys;[sys.stdout.write(os.path.expandvars(l)) for l in sys.stdin]'"
fi

# canonical hex dump; some systems have this symlinked
if ! (( $+commands[hd] )) && (( $+commands[hexdump] )); then
  alias hd="hexdump -C"
fi

# macOS-like open command
if ! (( $+commands[open] )); then
  if [[ "$OSTYPE" == cygwin* ]]; then
    alias open='cygstart'
  elif [[ "$OSTYPE" == linux-android ]]; then
    alias open='termux-open'
  elif (( $+commands[xdg-open] )); then
    alias open='xdg-open'
  fi
fi

# macOS-like pbcopy/pbpaste command
if ! (( $+commands[pbcopy] )); then
  if [[ "$OSTYPE" == cygwin* ]]; then
    alias pbcopy='tee > /dev/clipboard'
    alias pbpaste='cat /dev/clipboard'
  elif [[ "$OSTYPE" == linux-android ]]; then
    alias pbcopy='termux-clipboard-set'
    alias pbpaste='termux-clipboard-get'
  elif (( $+commands[wl-copy] && $+commands[wl-paste] )); then
    alias pbcopy='wl-copy'
    alias pbpaste='wl-paste'
  elif [[ -n $DISPLAY ]]; then
    if (( $+commands[xclip] )); then
      alias pbcopy='xclip -selection clipboard -in'
      alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
  fi
fi

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
alias help=run-help

#
# Misc
#

# Allow mapping Ctrl+S and Ctrl+Q shortcuts
[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

#
# Wrap up
#

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:utility" loaded 'yes'
