# Drive one scenario against a real interactive zsh under a pseudo-terminal.
#
# The pty shell's .zshrc loads the plugins named in $ZEPHYR_ZLE_PLUGINS, seeds a
# fixed history, and binds probe widgets that append numbered lines of editor
# state to a log. The scenario, a zsh file named in $1, is a key script built
# from the helpers below. Every helper probes after sending and blocks until the
# line lands, so there are no sleeps to tune and log order is event order. The
# log is the output.
emulate -L zsh
zmodload zsh/zpty
zmodload zsh/zselect

typeset -g log=$HOME/zle.log
typeset -gi expect=1
: >$log

cat >$ZDOTDIR/.zshrc <<'RC'
source $ZEPHYR_HOME/lib/bootstrap.zsh
for _p in ${=ZEPHYR_ZLE_PLUGINS}; do
  source $ZEPHYR_HOME/plugins/$_p/$_p.plugin.zsh
done
unset _p
# A scenario that needs something loaded after the plugins, such as a competing
# syntax highlighter, points $ZEPHYR_ZLE_RC at a file holding it.
[[ -n $ZEPHYR_ZLE_RC ]] && source $ZEPHYR_ZLE_RC

# A fixed history, so search scenarios have known matches. Oldest first.
print -s 'echo one'
print -s 'git status'
print -s 'echo two'
print -s 'git commit -v'

typeset -g ZLELOG=$HOME/zle.log
typeset -gi ZLEN=0
function zle-probe {
  print -r -- "$((++ZLEN)): BUF=[${BUFFER//$'\n'/|}] CUR=$CURSOR PRE=[${PREBUFFER//$'\n'/|}]" >>$ZLELOG
}
zle -N zle-probe
function zle-probe-hl {
  print -r -- "$((++ZLEN)): RH=[${(j:,:)region_highlight}]" >>$ZLELOG
}
zle -N zle-probe-hl
# vicmd as well, so a scenario can probe from vi command mode.
bindkey '^G' zle-probe
bindkey '^O' zle-probe-hl
bindkey -M vicmd '^G' zle-probe
bindkey -M vicmd '^O' zle-probe-hl
print ready >>$ZLELOG
RC

zpty -b z zsh -d -i

# Block until the log reaches $expect lines, draining the pty as we go so the
# shell never stalls on a full terminal buffer.
function await {
  local -i deadline=$((SECONDS + 10))
  local chunk
  while (( $(wc -l <$log) < expect )); do
    while zpty -r z chunk 2>/dev/null; do :; done
    if (( SECONDS >= deadline )); then
      print -r -- "timed out waiting for probe line $expect"
      cat $log
      exit 1
    fi
    zselect -t 2 2>/dev/null || :
  done
}

function probe {
  zpty -w -n z $'\a'
  (( expect += 1 ))
  await
}

# Log the highlight regions instead of the buffer.
function probe-hl {
  zpty -w -n z $'\x0f'
  (( expect += 1 ))
  await
}

# One keypress by name, or any literal byte sequence.
function press {
  local -A key=(
    up $'\eOA' down $'\eOB' left $'\eOD' right $'\eOC'
    xup $'\e[A' xdown $'\e[B'
    escape $'\e' intr $'\x03' enter $'\r'
  )
  zpty -w -n z "${key[$1]:-$1}"
  probe
}

# Self-inserting text, without Enter.
function type-keys {
  zpty -w -n z "$1"
  probe
}

# A full line, Enter included.
function enter {
  zpty -w -n z "$1"$'\r'
  probe
}

await
source $1
zpty -d z
cat $log
