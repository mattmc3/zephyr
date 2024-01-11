#
# utility - Misc Zsh shell options and utilities.
#

# References:
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh
# - https://github.com/sorin-ionescu/prezto/blob/master/modules/utility/init.zsh
# - https://github.com/belak/zsh-utils/blob/main/utility/utility.plugin.zsh

# Bootstrap.
0=${(%):-%N}
zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:a:h:h:h}/lib/bootstrap.zsh
-zephyr-autoload-dir ${0:a:h}/functions

# Set Zsh options related to globbing.
setopt extended_glob         # Use more awesome globbing features.
setopt glob_dots             # Include dotfiles when globbing.
setopt no_rm_star_silent     # Ask for confirmation for `rm *' or `rm path/*'

# Set general Zsh options.
setopt combining_chars       # Combine 0-len chars with the base character (eg: accents).
setopt interactive_comments  # Enable comments in interactive shell.
setopt rc_quotes             # Allow 'Hitchhikers''s Guide' instead of 'Hitchhikers'\''s Guide'.
setopt NO_mail_warning       # Don't print a warning message if a mail file has been accessed.
setopt NO_beep               # Don't beep on error in line editor.

# Set Zsh job options.
setopt long_list_jobs        # List jobs in the long format by default.
setopt auto_resume           # Attempt to resume existing job before creating a new process.
setopt notify                # Report status of background jobs immediately.
setopt NO_bg_nice            # Don't run all background jobs at a lower priority.
setopt NO_hup                # Don't kill jobs on shell exit.
setopt NO_check_jobs         # Don't report on jobs when shell exit.

# Use built-in paste magic.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Ensure envsubst command exists.
if ! (( $+commands[envsubst] )); then
  alias envsubst="python -c 'import os,sys;[sys.stdout.write(os.path.expandvars(l)) for l in sys.stdin]'"
fi

# Ensure hd (hex dump) exists.
if ! (( $+commands[hd] )) && (( $+commands[hexdump] )); then
  alias hd="hexdump -C"
fi

# Ensure open command exists.
if ! (( $+commands[open] )); then
  if [[ "$OSTYPE" == cygwin* ]]; then
    alias open='cygstart'
  elif [[ "$OSTYPE" == linux-android ]]; then
    alias open='termux-open'
  elif (( $+commands[xdg-open] )); then
    alias open='xdg-open'
  fi
fi

# Ensure pbcopy/pbpaste commands exist.
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

# Tell Zephyr this plugin is loaded.
zstyle ":zephyr:plugin:utility" loaded 'yes'
