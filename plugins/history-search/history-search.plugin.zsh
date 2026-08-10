#region HEADER
#
# history-search: Search history from Up and Down using what's already typed.
#

# Nothing from lib/bootstrap.zsh on purpose: this plugin works on its own, sourced
# straight out of its directory.
#endregion

# Return if requirements are not met.
[[ "$TERM" != 'dumb' ]] || return 1
! zstyle -t ":zephyr:plugin:history-search" skip || return 0

# Up and Down search history for the text already on the line: substring search
# from the first and last lines, move between lines anywhere else, and keep
# searching once started.
typeset -g _zph_search_query=
typeset -g _zph_search_result=
typeset -gi _zph_search_histno=0

# Still searching if the line is untouched since the last match and the cursor is
# still at the end, where a match parks it. Editing or moving the cursor leaves
# search. $LASTWIDGET cannot be the latch: an inner `zle` call rewrites it.
function history-search-in-progress {
  [[ -n "$_zph_search_result" && "$BUFFER" == "$_zph_search_result" ]] || return 1
  # vi command mode rests the cursor on the last character, not past it.
  local -i end=$#BUFFER
  [[ "$KEYMAP" == vicmd ]] && (( end-- ))
  (( CURSOR == end ))
}

# One step, $1 up or down. HISTNO never moves: zle stashes buffer edits on every
# entry it leaves, and a stashed blank kills downward motion.
function history-search-step {
  local -i i step last=$((HISTNO - 1))
  if ! history-search-in-progress; then
    _zph_search_query=$BUFFER
    _zph_search_histno=$HISTNO
  fi
  [[ "$1" == up ]] && step=-1 || step=1
  for (( i = _zph_search_histno + step; i >= 1 && i <= last; i += step )); do
    [[ -n "$history[$i]" && "$history[$i]" == *"$_zph_search_query"* ]] || continue
    [[ "$history[$i]" == "$BUFFER" ]] && continue
    BUFFER=$history[$i]
    _zph_search_histno=$i
    _zph_search_result=$BUFFER
    CURSOR=$#BUFFER
    return
  done
  # Down past the newest match restores the typed line.
  if [[ "$1" == down ]]; then
    BUFFER=$_zph_search_query
    _zph_search_histno=$HISTNO
    _zph_search_result=
    CURSOR=$#BUFFER
  fi
}

# Paint the matched substring, and unpaint on the edit that ends the search. The
# memo tag marks the span as ours; it needs zsh 5.9. The last span covering a
# character wins and highlighters append theirs on every redraw, so re-register at
# the first prompt to run after any highlighter loaded later.
autoload -Uz is-at-least add-zle-hook-widget add-zsh-hook
function history-search-highlight {
  region_highlight=(${region_highlight:#*memo=zephyr-history-search})
  history-search-in-progress && [[ -n "$_zph_search_query" ]] || return 0
  local style prefix=${BUFFER%%"$_zph_search_query"*}
  [[ "$prefix" == "$BUFFER" ]] && return 0
  zstyle -s ':zephyr:plugin:history-search' highlight style || style=standout
  region_highlight+=("$#prefix $(($#prefix + $#_zph_search_query)) $style memo=zephyr-history-search")
}
# Runs at the first prompt, by which point every highlighter has had its say, then
# takes itself off precmd. A plain precmd hook rather than Zephyr's post_zshrc, so
# this plugin keeps working on its own.
function history-search-highlight-last {
  add-zle-hook-widget -d line-pre-redraw history-search-highlight
  add-zle-hook-widget line-pre-redraw history-search-highlight
  add-zsh-hook -d precmd history-search-highlight-last
}

# A half-typed multi-line command lives in $PREBUFFER with only the PS2 line in
# $BUFFER, so pull the whole construct into one buffer first.
function history-search-pull-prebuffer {
  [[ -n "$PREBUFFER" ]] || return 1
  _zph_search_result=
  zle .push-line-or-edit
}

function up-line-or-history-search {
  if history-search-in-progress; then
    history-search-step up
  elif ! history-search-pull-prebuffer; then
    if [[ "$LBUFFER" == *$'\n'* ]]; then
      _zph_search_result=
      zle .up-line
    else
      history-search-step up
    fi
  fi
}
zle -N up-line-or-history-search

function down-line-or-history-search {
  if history-search-in-progress; then
    history-search-step down
  elif ! history-search-pull-prebuffer; then
    if [[ "$RBUFFER" == *$'\n'* ]]; then
      _zph_search_result=
      zle .down-line
    else
      history-search-step down
    fi
  fi
}
zle -N down-line-or-history-search

# The sequences we claim. terminfo names only the arrow its terminal sends, so the
# xterm and SS3 forms are listed alongside it; a stray SS3 arrow would otherwise
# miss the search widgets entirely.
zmodload zsh/terminfo 2>/dev/null
typeset -ga _zph_hs_keymaps=(emacs viins vicmd)
typeset -ga _zph_hs_upkeys=("${terminfo[kcuu1]-}" '^[[A' '^[OA')
typeset -ga _zph_hs_downkeys=("${terminfo[kcud1]-}" '^[[B' '^[OB')

# Bind Up and Down in each keymap, skipping sequences the terminal doesn't report.
# All builtins, so this is cheap enough to repeat.
function history-search-bindkeys {
  local km seq
  for km in $_zph_hs_keymaps; do
    for seq in $_zph_hs_upkeys; do
      [[ -n "$seq" ]] && bindkey -M $km "$seq" up-line-or-history-search
    done
    for seq in $_zph_hs_downkeys; do
      [[ -n "$seq" ]] && bindkey -M $km "$seq" down-line-or-history-search
    done
  done
}

# Bind the keys yourself with:
#   zstyle ':zephyr:plugin:history-search' bindkeys 'no'
if zstyle -T ':zephyr:plugin:history-search' bindkeys; then
  history-search-bindkeys
fi

if is-at-least 5.9; then
  add-zle-hook-widget line-pre-redraw history-search-highlight
  add-zsh-hook precmd history-search-highlight-last
fi

#region MARK LOADED
zstyle ':zephyr:plugin:history-search' loaded 'yes'
#endregion
