#!/usr/bin/env bats
# Every plugin has to load on its own, sourced straight out of its directory the way
# a plugin manager does it: no zephyr.zsh, no bootstrap first, and no $ZEPHYR_HOME in
# the environment. A plugin that needs anything from the bootstrap has to say so.
#
# The check is stderr, not exit status. Plugins whose requirements are unmet return 1
# on purpose, and a missing function is a message rather than a failed source.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

_all_plugins() {
  local d
  for d in "$PRJDIR"/plugins/*/; do
    d="${d%/}"
    printf '%s\n' "${d##*/}"
  done
}

# Source one plugin in a bare zsh and hand back whatever it wrote to stderr.
_standalone_stderr() {
  local plugin="$1" pre="${2:-}"
  _zephyr_env zsh -f -c "
    unset ZEPHYR_HOME ZEPHYR
    $pre
    source '$PRJDIR/plugins/$plugin/$plugin.plugin.zsh'
  " 2>&1 >/dev/null
}

# Run every plugin through _standalone_stderr and fail with the ones that complained.
_assert_all_quiet() {
  local pre="${1:-}" plugin out errs=""
  for plugin in $(_all_plugins); do
    out="$(_standalone_stderr "$plugin" "$pre")"
    [[ -z "$out" ]] || errs+="$plugin: $out"$'\n'
  done
  [[ -z "$errs" ]] && return 0
  printf 'plugins failed to load standalone:\n%s' "$errs" >&2
  return 1
}

@test "every plugin loads on its own" {
  _assert_all_quiet
}

# use-cache routes work through cached-eval, which lives in functions/ and only
# exists once the bootstrap has put that directory on $fpath.
@test "every plugin loads on its own with use-cache set" {
  _assert_all_quiet "zstyle ':zephyr:plugin:*' use-cache yes"
}

@test "every plugin loads on its own with use-xdg-basedirs set" {
  _assert_all_quiet "zstyle ':zephyr:plugin:*' use-xdg-basedirs yes"
}
