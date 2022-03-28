#
# Set shell options and setup environment
#

#region: Functions

0=${(%):-%x}
(( $+functions[autoload-dir] )) || autoload ${0:A:h:h}/functions/autoload-dir
autoload-dir "${0:A:h}/functions"

#endregion

#region: Smart URLs

# This logic comes from an old version of zim. Essentially, bracketed-paste was
# added as a requirement of url-quote-magic in 5.1, but in 5.1.1 bracketed
# paste had a regression. Additionally, 5.2 added bracketed-paste-url-magic
# which is generally better than url-quote-magic so we load that when possible.
autoload -Uz is-at-least
if [[ ${ZSH_VERSION} != 5.1.1 && ${TERM} != "dumb" ]]; then
  if is-at-least 5.2; then
    autoload -Uz bracketed-paste-url-magic
    zle -N bracketed-paste bracketed-paste-url-magic
  elif is-at-least 5.1; then
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
  fi
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
fi

#endregion

#region: Options

# general options
setopt COMBINING_CHARS       # combine zero-length punctuation characters (accents)
                             #   with the base character
setopt INTERACTIVE_COMMENTS  # enable comments in interactive shell
setopt RC_QUOTES             # allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
unsetopt MAIL_WARNING        # don't print a warning message if a mail file has been accessed

# job options
setopt LONG_LIST_JOBS        # list jobs in the long format by default
setopt AUTO_RESUME           # attempt to resume existing job before creating a new process
setopt NOTIFY                # report status of background jobs immediately
unsetopt BG_NICE             # don't run all background jobs at a lower priority
unsetopt HUP                 # don't kill jobs on shell exit
unsetopt CHECK_JOBS          # don't report on jobs when shell exit

#endregion

#region: Shortcuts

# Allow mapping Ctrl+S and Ctrl+Q shortcuts
[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

#endregion
