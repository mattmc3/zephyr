# Auxiliary history: record every command to a structured file alongside HISTFILE.
#
# This file holds what every backend shares: the hooks, the per-command state, and
# the dispatch loop. A backend lives in its own aux_*.zsh file next to this one,
# named for the zstyle that turns it on (aux_sqlite.zsh ->
# ':zephyr:plugin:history:aux:sqlite'), and provides:
#   _zsh_aux_hist_<name>_init <file>     prepare the file, non-zero if unusable
#   _zsh_aux_hist_<name>_insert <file> <sid> <cwd> <cmd> <ret> <pipes> <start> <end>
# plus a default path in $_zsh_aux_hist_defaults and its name in
# $_zsh_aux_hist_backends. A backend that can revisit a record it already wrote may
# also provide, to run before the command does:
#   _zsh_aux_hist_<name>_start <file> <sid> <cwd> <cmd> <start>

0=${(%):-%N}
if (( ! ${+functions[gen-uuid7]} )); then
  zstyle -t ':zephyr:lib:bootstrap' loaded || source ${0:A:h:h:h:h}/lib/bootstrap.zsh
fi

zmodload zsh/datetime 2>/dev/null
typeset -gA _zsh_aux_hist_state
if [[ -n "${_zsh_aux_hist_state[loaded]:-}" ]]; then
  return 0
fi
_zsh_aux_hist_state[loaded]=1

typeset -ga _zsh_aux_hist_backends=()
typeset -gA _zsh_aux_hist_defaults=()

# Resolve the file a backend writes to, preparing it the first time. Sets $REPLY,
# and returns non-zero when the backend is off or its file is unusable.
_zsh_aux_hist_resolve() {
  local backend="$1" f
  zstyle -t ":zephyr:plugin:history:aux:$backend" enable || return 1
  zstyle -s ":zephyr:plugin:history:aux:$backend" histfile 'f' \
    || f="${_zsh_aux_hist_defaults[$backend]}"
  if [[ "${_zsh_aux_hist_state[${backend}_init]}" != "$f" ]]; then
    "_zsh_aux_hist_${backend}_init" "$f" && _zsh_aux_hist_state[${backend}_init]="$f"
  fi
  [[ "${_zsh_aux_hist_state[${backend}_init]}" == "$f" ]] || return 1
  REPLY="$f"
}

_zsh_aux_hist_preexec() {
  local _ignore_space=$options[hist_ignore_space]
  local _reduce_blanks=$options[hist_reduce_blanks]
  emulate -L zsh
  setopt local_options extended_glob

  local cmd="$1"
  [[ -z "$cmd" ]] && return 0
  [[ "$_ignore_space" == on && "$cmd[1]" == ' ' ]] && return 0

  if [[ "$_reduce_blanks" == on ]]; then
    cmd="${${${cmd//[[:blank:]][[:blank:]]##/ }##[[:blank:]]##}%%[[:blank:]]##}"
  fi

  _zsh_aux_hist_state[cmd]="$cmd"
  _zsh_aux_hist_state[start_ts]="$EPOCHREALTIME"
  # Where the command was launched, not where it left the shell sitting.
  _zsh_aux_hist_state[cwd]="$PWD"

  # Written before the command runs, so one that outlives the shell is on disk.
  local backend
  for backend in $_zsh_aux_hist_backends; do
    (( $+functions[_zsh_aux_hist_${backend}_start] )) || continue
    _zsh_aux_hist_resolve "$backend" || continue
    "_zsh_aux_hist_${backend}_start" "$REPLY" "${_zsh_aux_hist_state[session]}" \
      "$PWD" "$cmd" "${_zsh_aux_hist_state[start_ts]}" &|
  done
}

_zsh_aux_hist_precmd() {
  local -a _ps=("${pipestatus[@]}")
  emulate -L zsh
  setopt local_options

  local my_pipestatus="${(j:,:)_ps}"
  local ret="${_ps[-1]}"
  # Empty when preexec passed on this command.
  [[ -z "${_zsh_aux_hist_state[cmd]:-}" ]] && return 0

  local end_ts start_ts cmd cwd sid backend
  cmd="${_zsh_aux_hist_state[cmd]}"

  end_ts="$EPOCHREALTIME"
  start_ts="${_zsh_aux_hist_state[start_ts]:-0}"
  cwd="${_zsh_aux_hist_state[cwd]:-$PWD}"
  sid="${_zsh_aux_hist_state[session]}"

  # A backend is prepared once per file it writes to, and only if it is enabled, so
  # the cost of a backend you never turn on is one zstyle lookup per command.
  for backend in $_zsh_aux_hist_backends; do
    _zsh_aux_hist_resolve "$backend" || continue
    "_zsh_aux_hist_${backend}_insert" "$REPLY" "$sid" "$cwd" "$cmd" "$ret" "$my_pipestatus" "$start_ts" "$end_ts" &|
  done

  unset '_zsh_aux_hist_state[cmd]'
  unset '_zsh_aux_hist_state[start_ts]'
  unset '_zsh_aux_hist_state[cwd]'
}

# Every backend is loaded, whether or not it is enabled, so a zstyle set after this
# point still works.
for _zsh_aux_hist_file in ${0:A:h}/aux_*.zsh(N); do
  [[ "${_zsh_aux_hist_file:t}" == aux_common.zsh ]] || source "$_zsh_aux_hist_file"
done
unset _zsh_aux_hist_file

autoload -Uz add-zsh-hook
add-zsh-hook preexec _zsh_aux_hist_preexec
add-zsh-hook precmd _zsh_aux_hist_precmd

# Run first so pipestatus isn't clobbered by other precmd hooks.
precmd_functions=(_zsh_aux_hist_precmd ${precmd_functions:#_zsh_aux_hist_precmd})

gen-uuid7 >/dev/null
_zsh_aux_hist_state[session]="$REPLY"
