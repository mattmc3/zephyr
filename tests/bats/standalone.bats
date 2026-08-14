#!/usr/bin/env bats
# Every plugin has to load on its own the way a plugin manager sources it: no
# zephyr.zsh, no bootstrap first, no $ZEPHYR_HOME. The check is stderr, not exit
# status, since a plugin whose requirements are unmet returns 1 on purpose.

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
    # bats runs under set -e, so drop the status rather than inherit it.
    out="$(_standalone_stderr "$plugin" "$pre")" || true
    [[ -z "$out" ]] || errs+="$plugin: $out"$'\n'
  done
  if [[ -n "$errs" ]]; then
    printf 'plugins failed to load standalone:\n%s' "$errs" >&2
    return 1
  fi
}

@test "every plugin loads on its own" {
  _assert_all_quiet
}

# cached-eval is only autoloadable once the bootstrap has put functions/ on $fpath.
@test "every plugin loads on its own with use-cache set" {
  _assert_all_quiet "zstyle ':zephyr:plugin:*' use-cache yes"
}

@test "every plugin loads on its own with use-xdg-basedirs set" {
  _assert_all_quiet "zstyle ':zephyr:plugin:*' use-xdg-basedirs yes"
}
