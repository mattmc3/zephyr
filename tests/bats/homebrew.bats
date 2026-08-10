#!/usr/bin/env bats
# Homebrew shellenv, fpath additions, and aliases.

load helpers/common

# A fake brew whose shellenv is predictable, in a prefix we control.
setup() {
  zephyr_setup
  BREW_PREFIX="$TEST_HOME/brewprefix"
  mkdir -p "$BREW_PREFIX/bin" "$BREW_PREFIX/share/zsh/site-functions"
  stub_command brew "
    [[ \$1 == shellenv ]] || exit 1
    print 'export HOMEBREW_PREFIX=$BREW_PREFIX'
    print 'export HOMEBREW_CELLAR=$BREW_PREFIX/Cellar'
    print 'path=($BREW_PREFIX/bin \$path)'
  "
}
teardown() { zephyr_teardown; }

@test "brew shellenv is applied" {
  zephyr_plugin homebrew <<'EOS'
print "prefix: ${HOMEBREW_PREFIX#$HOME/}"
print "cellar: ${HOMEBREW_CELLAR#$HOME/}"
EOS
  assert_success
  assert_line "prefix: brewprefix"
  assert_line "cellar: brewprefix/Cellar"
}

@test "analytics are off unless already set" {
  zephyr_plugin homebrew 'print "analytics: $HOMEBREW_NO_ANALYTICS"'
  assert_success
  assert_line "analytics: 1"
}

@test "an existing analytics choice is kept" {
  zephyr_zsh <<'EOS'
export HOMEBREW_NO_ANALYTICS=0
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
print "analytics: $HOMEBREW_NO_ANALYTICS"
EOS
  assert_success
  assert_line "analytics: 0"
}

# Counted through an array: inside double quotes zsh joins $fpath to a scalar
# before applying :#, so the match has to happen outside the quotes.
@test "the brewed site-functions directory joins fpath" {
  zephyr_plugin homebrew <<'EOS'
local -a m=(${(M)fpath:#$HOMEBREW_PREFIX/share/zsh/site-functions})
print "in fpath: $#m"
EOS
  assert_success
  assert_line "in fpath: 1"
}

@test "keg-only completions join fpath" {
  mkdir -p "$TEST_HOME/brewprefix/opt/curl/share/zsh/site-functions"
  zephyr_plugin homebrew <<'EOS'
local -a m=(${(M)fpath:#$HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions})
print "curl: $#m"
EOS
  assert_success
  assert_line "curl: 1"
}

@test "the keg-only list can be overridden" {
  mkdir -p "$TEST_HOME/brewprefix/opt/openssl/share/zsh/site-functions"
  mkdir -p "$TEST_HOME/brewprefix/opt/curl/share/zsh/site-functions"
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:homebrew' keg-only-brews openssl
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
local -a o=(${(M)fpath:#$HOMEBREW_PREFIX/opt/openssl/share/zsh/site-functions})
local -a c=(${(M)fpath:#$HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions})
print "openssl: $#o"
print "curl: $#c"
EOS
  assert_success
  assert_line "openssl: 1"
  assert_line "curl: 0"
}

# brew shellenv prepends to path, which would otherwise leave user bins behind it.
@test "user bins stay ahead of the brew prefix" {
  zephyr_zsh <<'EOS'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/environment/environment.plugin.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
print "first: ${path[1]#$HOME/}"
EOS
  assert_success
  assert_line "first: bin"
}

@test "the aliases and brewdeps function are set" {
  zephyr_plugin homebrew <<'EOS'
print "brewup: $aliases[brewup]"
print "brewinfo: $+aliases[brewinfo]"
print "brewdeps: $+functions[brewdeps]"
EOS
  assert_success
  assert_line "brewup: brew update && brew upgrade && brew cleanup"
  assert_line "brewinfo: 1"
  assert_line "brewdeps: 1"
}

@test "the alias skip zstyle suppresses them" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:homebrew:alias' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
print "brewup: $+aliases[brewup]"
print "brewdeps: $+functions[brewdeps]"
EOS
  assert_success
  assert_line "brewup: 0"
  assert_line "brewdeps: 0"
}

@test "the cache zstyle routes shellenv through cached-eval" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:homebrew' use-cache yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
print "prefix: ${HOMEBREW_PREFIX#$HOME/}"
print "cached: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "prefix: brewprefix"
  assert_line "cached: 1"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:homebrew' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
print "prefix: ${HOMEBREW_PREFIX:-unset}"
EOS
  assert_success
  assert_line "prefix: unset"
}

# brew is looked up on PATH first, then at a list of absolute paths, so a brew
# that is installed but not on PATH is still found.
@test "brew is found at a known path even when not on PATH" {
  mkdir -p "$TEST_HOME/.linuxbrew/bin"
  cp "$TEST_HOME/bin/brew" "$TEST_HOME/.linuxbrew/bin/brew"
  rm -f "$TEST_HOME/bin/brew"
  # $path keeps coreutils but drops every directory a real brew lives in, so the
  # absolute-path fallback is what finds it.
  zephyr_zsh <<'EOS'
path=(/usr/bin /bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/homebrew/homebrew.plugin.zsh
print "brew on path: $+commands[brew]"
print "prefix: ${HOMEBREW_PREFIX#$HOME/}"
EOS
  assert_success
  assert_line "brew on path: 0"
  assert_line "prefix: brewprefix"
}
