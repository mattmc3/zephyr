# Shared harness for the Zephyr bats tests.
#
# No assertion libraries. The helpers below are plain bash and dump the captured
# output when they fail, which is all bats-assert was buying us.
#
# bats runs in bash and Zephyr is zsh, so every test hands a body to a real zsh
# and inspects what comes back. zephyr_zsh does that in an isolated HOME with its
# own XDG dirs, with $ZEPHYR pointing at zephyr.zsh and $ZEPHYR_HOME at the
# checkout. Pass the body as an argument, or on stdin when it is long enough that
# quoting would hurt. Bodies source what they need themselves rather than having
# the harness do it, because half of what we test is a zstyle set *before* a
# plugin loads.
#
# Session bodies should print facts, not verdicts. `[[ $x == y ]] && echo ok`
# tells you nothing about what x was when it fails, so print x and assert here.

zephyr_setup() {
  PRJDIR="$BATS_TEST_DIRNAME"
  while [[ ! -f "$PRJDIR/zephyr.zsh" && "$PRJDIR" != / ]]; do
    PRJDIR="$(dirname "$PRJDIR")"
  done
  [[ -f "$PRJDIR/zephyr.zsh" ]] || {
    echo "cannot find zephyr.zsh above $BATS_TEST_DIRNAME" >&2
    return 1
  }

  TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/zephyr-test.XXXXXX")" || return 1
  # $TMPDIR often ends in a slash, and may be a symlink. Normalize, or $PWD and
  # $HOME never compare equal and nothing shortens paths to ~.
  TEST_HOME="$(cd "$TEST_HOME" && pwd -P)" || return 1
  mkdir -p "$TEST_HOME/bin" \
           "$TEST_HOME/.config/zsh" \
           "$TEST_HOME/.cache" \
           "$TEST_HOME/.local/share"
}

zephyr_teardown() {
  # Only ever delete a directory named the way zephyr_setup names them.
  case "$TEST_HOME" in
    */zephyr-test.??????) rm -rf "$TEST_HOME" ;;
  esac
}

# The env every session runs under: no inherited settings, disposable $HOME.
# $HOME/bin leads PATH so stub_command shadows the real thing even in a session
# that never loads the environment plugin and so never builds $prepath.
_zephyr_env() {
  env -i \
    PATH="$TEST_HOME/bin:${ZEPHYR_TEST_PATH:-$PATH}" \
    HOME="$TEST_HOME" \
    ZDOTDIR="$TEST_HOME/.config/zsh" \
    XDG_CONFIG_HOME="$TEST_HOME/.config" \
    XDG_CACHE_HOME="$TEST_HOME/.cache" \
    XDG_DATA_HOME="$TEST_HOME/.local/share" \
    TERM=xterm-256color \
    ZEPHYR_HOME="$PRJDIR" \
    ZEPHYR="$PRJDIR/zephyr.zsh" \
    "$@"
}

# Run a zsh session over the given body, or over stdin when given no arguments.
zephyr_zsh() {
  local body
  if (( $# )); then
    body="$*"
  else
    body="$(cat)"
  fi
  run _zephyr_env zsh -f -c "$body"
}

# Same, but with a plugin already sourced, for the common case where the test
# does not care about pre-load zstyles. `zephyr_plugin color 'print $aliases[ls]'`
zephyr_plugin() {
  local plugin="$1"; shift
  local body
  if (( $# )); then
    body="$*"
  else
    body="$(cat)"
  fi
  run _zephyr_env zsh -f -c "
    source \$ZEPHYR_HOME/lib/bootstrap.zsh
    source \$ZEPHYR_HOME/plugins/$plugin/$plugin.plugin.zsh
    $body"
}

# Drive a real zle session under a pseudo-terminal. The body is a key script for
# the zletest.zsh helpers; the output is the numbered probe log. Set
# $ZEPHYR_ZLE_RC to a file to have the session load it after the plugins, and
# $ZEPHYR_ZLE_PLUGINS to the plugin list the session should load.
zephyr_zle() {
  local body
  if (( $# )); then
    body="$*"
  else
    body="$(cat)"
  fi
  printf '%s\n' "$body" >"$TEST_HOME/scenario.zsh"
  run _zephyr_env \
    ZEPHYR_ZLE_RC="${ZEPHYR_ZLE_RC:-}" \
    ZEPHYR_ZLE_PLUGINS="${ZEPHYR_ZLE_PLUGINS:-editor}" \
    zsh "$PRJDIR/tests/bats/helpers/zletest.zsh" "$TEST_HOME/scenario.zsh"
}

# Write an executable stub into $HOME/bin. That directory is in Zephyr's default
# prepath, so a stub shadows the real command even when one is installed.
stub_command() {
  local name="$1"; shift
  printf '#!/usr/bin/env zsh\n%s\n' "$*" >"$TEST_HOME/bin/$name"
  chmod +x "$TEST_HOME/bin/$name"
}

# Write a file, one line per argument, creating its directory first.
write_file() {
  local path="$1"; shift
  mkdir -p "${path%/*}"
  printf '%s\n' "$@" >"$path"
}

_dump_output() {
  printf -- '--- status: %s\n--- output ---\n%s\n--------------\n' \
    "$status" "$output" >&2
}

assert_success() {
  [[ "$status" -eq 0 ]] && return 0
  echo "expected success, got status $status" >&2
  _dump_output
  return 1
}

assert_failure() {
  [[ "$status" -ne 0 ]] && return 0
  echo "expected failure, got status 0" >&2
  _dump_output
  return 1
}

# Exact match against a whole line of output.
assert_line() {
  local want="$1" line
  while IFS= read -r line; do
    [[ "$line" == "$want" ]] && return 0
  done <<<"$output"
  echo "expected line: $want" >&2
  _dump_output
  return 1
}

refute_line() {
  local want="$1" line
  while IFS= read -r line; do
    if [[ "$line" == "$want" ]]; then
      echo "unexpected line: $want" >&2
      _dump_output
      return 1
    fi
  done <<<"$output"
  return 0
}

assert_output_contains() {
  [[ "$output" == *"$1"* ]] && return 0
  echo "expected output to contain: $1" >&2
  _dump_output
  return 1
}

refute_output_contains() {
  [[ "$output" != *"$1"* ]] && return 0
  echo "expected output not to contain: $1" >&2
  _dump_output
  return 1
}
