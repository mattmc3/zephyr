###
# history - Set Zsh history options.
###

#
# Options
#

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt NO_HIST_BEEP              # Do not beep when accessing non-existent history.

#
# Variables
#

zstyle -s ':zephyr:plugin:history' histfile '_histfile' || _histfile="${XDG_DATA_HOME:=~/.local/share}/zsh/history"
zstyle -s ':zephyr:plugin:history' histsize '_histsize' || _histsize=10000
zstyle -s ':zephyr:plugin:history' savehist '_savehist' || _savehist=10000

HISTFILE="${_histfile}"  # path to the history file
HISTSIZE="${_histsize}"  # max history events in session
SAVEHIST="${_savehist}"  # max history events saved to history file
unset _hist{file,size} _savehist

# Make sure the path to the history file exists
[[ -f $HISTFILE ]] || { mkdir -p ${HISTFILE:h} && touch $HISTFILE }

#
# Aliases
#

if ! zstyle -t ':zephyr:plugin:history:alias' skip; then
  # Lists the ten most used commands.
  alias history-stat="command history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"
  alias hist='fc -l -i'
fi
