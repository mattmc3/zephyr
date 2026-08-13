#region HEADER
#
# autosuggest: Suggest commands from history as you type.
#

# Nothing from lib/bootstrap.zsh on purpose: this plugin works on its own, sourced
# straight out of its directory.
#endregion

# Return if requirements are not met.
[[ "$TERM" != 'dumb' ]] || return 1
! zstyle -t ":zephyr:plugin:autosuggest" skip || return 0
autoload -Uz is-at-least add-zle-hook-widget add-zsh-hook
is-at-least 5.9 || return 1

# The best match for what is on the line is shown after the cursor, dimmed. Right
# arrow or Ctrl+E takes all of it, Alt+F takes a word, and anything else ignores it.
# The suggestion is recomputed on every redraw rather than by wrapping the editing
# widgets, so widgets added later need no special care.

# Longest line still worth searching for. A prefix this long has usually stopped
# matching anything anyway.
typeset -gi _zph_suggest_max=300

# The last line looked up and what it produced. line-pre-redraw can fire several
# times per keypress, and the answer only changes when the line does. The shortest
# line known to match nothing is worth keeping too: no longer line starting with it
# can match either, so a whole word can be typed out after a miss without searching
# again. A strategy of your own may not work that way, so only the history one gets
# the shortcut.
typeset -g _zph_suggest_buffer=
typeset -g _zph_suggest_result=
typeset -g _zph_suggest_miss=

# The default strategy: the most recent history entry starting with $1. Replace it
# with your own, which sets $suggestion rather than printing, since a command
# substitution on every keypress means a fork on every keypress:
#   zstyle ':zephyr:plugin:autosuggest' strategy 'my-suggester'
function autosuggest-history {
  emulate -L zsh
  setopt extended_glob
  suggestion=${history[(r)${(b)1}*]}
}

# True when a suggestion would be in the way rather than helpful.
function autosuggest-suppressed {
  [[ -z "$BUFFER" || $#BUFFER -gt $_zph_suggest_max ]] && return 0
  # PS2 lines and multi-line buffers already have text below the cursor.
  [[ -n "$PREBUFFER" || "$BUFFER" == *$'\n'* ]] && return 0
  # Only while typing: not in vi command mode, and not in an isearch.
  [[ "$KEYMAP" == (vicmd|isearch) ]] && return 0
  # Up and Down search fills the line itself and paints its own match.
  (( $+functions[history-search-in-progress] )) && history-search-in-progress
}

# Put the suggestion in POSTDISPLAY, which zle shows after the cursor without it
# being part of the line. The memo tag marks the highlight as ours so the next
# redraw can drop it, the same way the history search highlight does.
function autosuggest-fetch {
  region_highlight=(${region_highlight:#*memo=zephyr-autosuggest})
  POSTDISPLAY=

  # An empty line is a fresh one, and the command just run may be the very thing a
  # remembered miss says not to look for.
  [[ -n "$BUFFER" ]] || _zph_suggest_miss=

  autosuggest-suppressed && return 0

  if [[ "$BUFFER" != "$_zph_suggest_buffer" ]]; then
    local strategy suggestion=
    zstyle -s ':zephyr:plugin:autosuggest' strategy strategy ||
      strategy=autosuggest-history

    if [[ "$strategy" == autosuggest-history && -n "$_zph_suggest_miss" &&
          "$BUFFER" == "$_zph_suggest_miss"* ]]; then
      _zph_suggest_buffer=$BUFFER
      _zph_suggest_result=
      return 0
    fi

    (( $+functions[$strategy] )) || return 0
    $strategy "$BUFFER"
    _zph_suggest_buffer=$BUFFER
    _zph_suggest_result=$suggestion
    [[ -n "$suggestion" ]] && _zph_suggest_miss= || _zph_suggest_miss=$BUFFER
  fi

  [[ -n "$_zph_suggest_result" && "$_zph_suggest_result" == "$BUFFER"* ]] || return 0
  POSTDISPLAY=${_zph_suggest_result#"$BUFFER"}
  [[ -n "$POSTDISPLAY" ]] || return 0

  local style
  zstyle -s ':zephyr:plugin:autosuggest' highlight style || style=fg=8
  region_highlight+=("$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $style memo=zephyr-autosuggest")
}

# Move the suggestion into the line. Not a widget: it reports whether there was
# anything to take, so the widgets below can fall back to their own job.
function autosuggest-take {
  [[ -n "$POSTDISPLAY" ]] && (( CURSOR == $#BUFFER )) || return 1
  BUFFER+=$POSTDISPLAY
  POSTDISPLAY=
  CURSOR=$#BUFFER
}

# Right arrow past the end of the line takes the whole suggestion, and anywhere else
# it still moves the cursor.
function autosuggest-forward-char {
  autosuggest-take || zle .forward-char
}
zle -N autosuggest-forward-char

function autosuggest-end-of-line {
  autosuggest-take || zle .end-of-line
}
zle -N autosuggest-end-of-line

# Take one word of the suggestion: the spaces before the next word, and the word
# itself. What is left is found again by the redraw that follows.
function autosuggest-forward-word {
  setopt local_options extended_glob
  if [[ -n "$POSTDISPLAY" ]] && (( CURSOR == $#BUFFER )); then
    BUFFER+=${(M)POSTDISPLAY##[[:space:]]#[^[:space:]]#}
    CURSOR=$#BUFFER
  else
    zle .forward-word
  fi
}
zle -N autosuggest-forward-word

# A finished line is redrawn one last time and then left on the screen, so the
# suggestion has to come off it first. Otherwise `ls -l` runs but the scrollback
# reads `ls -lah`.
function autosuggest-clear {
  region_highlight=(${region_highlight:#*memo=zephyr-autosuggest})
  POSTDISPLAY=
}

# Highlighters append to region_highlight on every redraw and the last span covering
# a character wins, so re-register at the first prompt to land after any highlighter
# loaded later. A plain precmd hook rather than Zephyr's post_zshrc, so this plugin
# keeps working on its own. It takes itself off precmd once it has run.
function autosuggest-highlight-last {
  add-zle-hook-widget -d line-pre-redraw autosuggest-fetch
  add-zle-hook-widget line-pre-redraw autosuggest-fetch
  # A plugin that claims zle-line-finish with its own `zle -N` throws away every hook
  # already on it, so put ours back once everything has loaded.
  add-zle-hook-widget -d line-finish autosuggest-clear
  add-zle-hook-widget line-finish autosuggest-clear
  add-zsh-hook -d precmd autosuggest-highlight-last
}

# The sequences we claim. terminfo names only the key its terminal sends, so the
# xterm and SS3 forms are listed alongside it. Suggestions are suppressed in vicmd,
# so only the insert keymaps are bound.
zmodload zsh/terminfo 2>/dev/null
typeset -ga _zph_as_keymaps=(emacs viins)
typeset -ga _zph_as_takekeys=("${terminfo[kcuf1]-}" '^[[C' '^[OC' '^F')
typeset -ga _zph_as_endkeys=('^E')
typeset -ga _zph_as_wordkeys=('^[f')

# Bind the take keys in each keymap, skipping sequences the terminal doesn't report.
# All builtins, so this is cheap enough to repeat.
function autosuggest-bindkeys {
  local km seq
  for km in $_zph_as_keymaps; do
    for seq in $_zph_as_takekeys; do
      [[ -n "$seq" ]] && bindkey -M $km "$seq" autosuggest-forward-char
    done
    for seq in $_zph_as_endkeys; do
      [[ -n "$seq" ]] && bindkey -M $km "$seq" autosuggest-end-of-line
    done
    for seq in $_zph_as_wordkeys; do
      [[ -n "$seq" ]] && bindkey -M $km "$seq" autosuggest-forward-word
    done
  done
}

# Bind the keys yourself with:
#   zstyle ':zephyr:plugin:autosuggest' bindkeys 'no'
if zstyle -T ':zephyr:plugin:autosuggest' bindkeys; then
  autosuggest-bindkeys
fi

add-zle-hook-widget line-pre-redraw autosuggest-fetch
add-zle-hook-widget line-finish autosuggest-clear
add-zsh-hook precmd autosuggest-highlight-last

#region MARK LOADED
zstyle ':zephyr:plugin:autosuggest' loaded 'yes'
#endregion
