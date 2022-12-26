###
# environment - Set general shell options and define environment variables.
###

#
# Options
#

# Set general options.
setopt COMBINING_CHARS       # Combine special chars into one char (ie: accents).
setopt INTERACTIVE_COMMENTS  # Enable comments in interactive shell.
setopt RC_QUOTES             # Allow 'Hitchhiker''s Guide' instead of 'Hitchhiker'\''s Guide'.
setopt NO_MAIL_WARNING       # Don't print a warning message if a mail file has been accessed.

# Set job options.
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

#
# Variables
#

# Set XDG base dirs.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-$HOME/.xdg}

if [[ "$OSTYPE" == darwin* ]]; then
  export XDG_DESKTOP_DIR=${XDG_DESKTOP_DIR:-$HOME/Desktop}
  export XDG_DOCUMENTS_DIR=${XDG_DOCUMENTS_DIR:-$HOME/Documents}
  export XDG_DOWNLOAD_DIR=${XDG_DOWNLOAD_DIR:-$HOME/Downloads}
  export XDG_MUSIC_DIR=${XDG_MUSIC_DIR:-$HOME/Music}
  export XDG_PICTURES_DIR=${XDG_PICTURES_DIR:-$HOME/Pictures}
  export XDG_VIDEOS_DIR=${XDG_VIDEOS_DIR:-$HOME/Videos}
  export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}
fi

# Set editors.
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-nano}"
export PAGER="${PAGER:-less}"

# Regional settings.
export LANG="${LANG:-en_US.UTF-8}"
export LANGUAGE="${LANGUAGE:-en}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Set the default Less options.
# Mouse-wheel scrolling is disabled with -X (disable screen clearing)
export LESS="${LESS:--g -i -M -R -S -w -z-4}"

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="${LESSOPEN:-| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-}"
fi

# macOS
if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="${BROWSER:-open}"
fi

# Use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER
