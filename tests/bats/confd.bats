#!/usr/bin/env bats
# Fish-style conf.d sourcing.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "conf.d files are sourced in name order" {
  write_file "$TEST_HOME/.config/zsh/conf.d/20-b.zsh" 'print two'
  write_file "$TEST_HOME/.config/zsh/conf.d/10-a.zsh" 'print one'
  write_file "$TEST_HOME/.config/zsh/conf.d/30-c.sh" 'print three'
  zephyr_plugin confd 'run_confd'
  assert_success
  assert_line "one"
  assert_line "two"
  assert_line "three"
  [[ "${lines[0]}" == one && "${lines[1]}" == two && "${lines[2]}" == three ]] || {
    _dump_output; return 1
  }
}

@test "a file starting with a tilde is parked, not sourced" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-on.zsh" 'print on'
  write_file "$TEST_HOME/.config/zsh/conf.d/~20-off.zsh" 'print off'
  zephyr_plugin confd 'run_confd'
  assert_success
  assert_line "on"
  refute_line "off"
}

# A directory named like a config file used to match the glob and get handed to
# source.
@test "a directory named like a config file is skipped" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-ok.zsh" 'print ok'
  mkdir -p "$TEST_HOME/.config/zsh/conf.d/20-adir.zsh"
  zephyr_plugin confd 'run_confd; print "exit: $?"'
  assert_success
  assert_line "ok"
  assert_line "exit: 0"
  refute_output_contains "not a file"
}

@test "a symlink to a config file is followed" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-real.zsh" 'print real'
  ln -s "$TEST_HOME/.config/zsh/conf.d/10-real.zsh" \
        "$TEST_HOME/.config/zsh/conf.d/20-link.zsh"
  zephyr_plugin confd 'run_confd'
  assert_success
  [[ "$(grep -c '^real$' <<<"$output")" -eq 2 ]] || { _dump_output; return 1; }
}

@test "other extensions are ignored" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-ok.zsh" 'print ok'
  write_file "$TEST_HOME/.config/zsh/conf.d/20-skip.txt" 'print nope'
  write_file "$TEST_HOME/.config/zsh/conf.d/30-skip.bash" 'print nope'
  zephyr_plugin confd 'run_confd'
  assert_success
  assert_line "ok"
  refute_line "nope"
}

@test "a missing conf.d directory is reported" {
  zephyr_plugin confd 'run_confd; print "exit: $?"'
  assert_success
  assert_output_contains "confd: dir not found"
  assert_line "exit: 1"
}

@test "the directory zstyle picks another location" {
  write_file "$TEST_HOME/.config/zsh/rc.d/10-a.zsh" 'print custom'
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:confd' directory "$HOME/.config/zsh/rc.d"
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/confd/confd.plugin.zsh
run_confd
EOS
  assert_success
  assert_line "custom"
}

@test "config files can set options that outlive the sourcing" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-opt.zsh" 'setopt ksh_arrays'
  zephyr_plugin confd <<'EOS'
run_confd
[[ -o ksh_arrays ]] && print "setopt: survived" || print "setopt: lost"
EOS
  assert_success
  assert_line "setopt: survived"
}

@test "run_confd is deferred to post_zshrc by default" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-a.zsh" 'print sourced'
  zephyr_plugin confd <<'EOS'
print "queued: ${post_zshrc_hook[(r)run_confd]:-none}"
run_post_zshrc
EOS
  assert_success
  assert_line "queued: run_confd"
  assert_line "sourced"
}

@test "the immediate zstyle sources conf.d at load time" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-a.zsh" 'print sourced'
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:confd' immediate yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/confd/confd.plugin.zsh
print "queued: ${post_zshrc_hook[(r)run_confd]:-none}"
EOS
  assert_success
  assert_line "sourced"
  assert_line "queued: none"
}

# Running it by hand takes it off the hook list, so post_zshrc has no work left.
@test "running run_confd early clears the hook" {
  write_file "$TEST_HOME/.config/zsh/conf.d/10-a.zsh" 'print sourced'
  zephyr_plugin confd <<'EOS'
run_confd
print "queued: ${post_zshrc_hook[(r)run_confd]:-none}"
EOS
  assert_success
  assert_line "sourced"
  assert_line "queued: none"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:confd' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/confd/confd.plugin.zsh
print "run_confd: $+functions[run_confd]"
EOS
  assert_success
  assert_line "run_confd: 0"
}
