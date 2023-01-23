###
# utility - Hodgepodge of Zsh shell options and utilities.
###

#
# Requirements
#

if ! zstyle -t ':zephyr:core' initialized; then
  source ${0:A:h:h}/zephyr/zephyr.plugin.zsh
fi

#
# Options
#

# General options.
setopt EXTENDED_GLOB         # Use more awesome globbing features.
setopt GLOB_DOTS             # Include dotfiles when globbing.
setopt COMBINING_CHARS       # Combine 0-len chars with the base character (eg: accents).
setopt INTERACTIVE_COMMENTS  # Enable comments in interactive shell.
setopt RC_QUOTES             # Allow 'Hitchhikers''s Guide' instead of 'Hitchhikers'\''s Guide'.
setopt NO_RM_STAR_SILENT     # Ask for confirmation for `rm *' or `rm path/*'
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
# Init
#

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Load more specific 'run-help' function from $fpath.
(( $+aliases[run-help] )) && unalias run-help && autoload -Uz run-help
alias help=run-help

# Autoload functions.
fpath=(${0:A:h}/functions $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Use zsh-bench.
export PATH="${0:A:h}/external/zsh-bench:$PATH"

#
# Wrap up
#

zstyle ":zephyr:plugin:utility" loaded 'yes'
