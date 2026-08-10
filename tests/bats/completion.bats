#!/usr/bin/env bats
# compinit, the compdef queue, and the dumpfile cache.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "the completion options are set" {
  zephyr_plugin completion <<'EOS'
for opt in always_to_end auto_list auto_menu auto_param_slash complete_in_word \
           path_dirs; do
  [[ -o $opt ]] || print "expected on: $opt"
done
for opt in flow_control list_beep menu_complete; do
  [[ -o $opt ]] && print "expected off: $opt"
done
print done
EOS
  assert_success
  assert_line "done"
  refute_output_contains "expected on:"
  refute_output_contains "expected off:"
}

# The menu-select styles the compstyles set need this module.
@test "zsh/complist is loaded" {
  zephyr_plugin completion 'zmodload -L | grep complist'
  assert_success
  assert_output_contains "zsh/complist"
}

@test "a dumb terminal turns the plugin off" {
  zephyr_zsh <<'EOS'
export TERM=dumb
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh
print "exit: $?"
EOS
  assert_success
  assert_line "exit: 1"
}

@test "compinit is deferred to post_zshrc by default" {
  zephyr_plugin completion <<'EOS'
print "queued: ${post_zshrc_hook[(r)run_compinit]:-none}"
print "compdef: $+functions[compdef]"
EOS
  assert_success
  assert_line "queued: run_compinit"
  assert_line "compdef: 1"
}

@test "the immediate zstyle runs compinit at load time" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:completion' immediate yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh
print "queued: ${post_zshrc_hook[(r)run_compinit]:-none}"
print "compdump: $([[ -s $ZSH_COMPDUMP ]] && print exists || print missing)"
EOS
  assert_success
  assert_line "queued: none"
  assert_line "compdump: exists"
}

@test "the dumpfile lands in the XDG cache dir" {
  zephyr_plugin completion <<'EOS'
run_compinit
print "compdump: ${ZSH_COMPDUMP#$HOME/}"
EOS
  assert_success
  assert_line "compdump: .cache/zsh/zcompdump"
}

@test "a preset ZSH_COMPDUMP wins, and expands a leading tilde" {
  zephyr_zsh <<'EOS'
ZSH_COMPDUMP='~/mydump'
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh
run_compinit
print "compdump: ${ZSH_COMPDUMP#$HOME/}"
EOS
  assert_success
  assert_line "compdump: mydump"
}

#
# The compdef queue. Plugins call compdef before fpath is fully built, so the
# calls are stashed and replayed when the real compinit runs.
#

@test "queued compdef calls survive quoting and are replayed" {
  zephyr_plugin completion <<'EOS'
compdef _gnu_generic foo
compdef _my 'cmd with spaces'
print "count: $#__compdef_queue"
print "entry1: $__compdef_queue[1]"
print "entry2: $__compdef_queue[2]"
EOS
  assert_success
  assert_line "count: 2"
  assert_line "entry1: _gnu_generic foo"
  assert_line "entry2: _my 'cmd with spaces'"
}

@test "the queue is drained once compinit runs" {
  zephyr_plugin completion <<'EOS'
compdef _gnu_generic mycmd
run_compinit
print "queue: ${__compdef_queue:-drained}"
print "queue var: $+parameters[__compdef_queue]"
print "mycmd: ${_comps[mycmd]:-unset}"
EOS
  assert_success
  assert_line "queue: drained"
  assert_line "queue var: 0"
  assert_line "mycmd: _gnu_generic"
}

@test "a bare compdef with no arguments queues nothing" {
  zephyr_plugin completion <<'EOS'
compdef
print "count: $#__compdef_queue"
EOS
  assert_success
  assert_line "count: 0"
}

#
# Dumpfile caching
#

# An age check alone would hide a new completion directory for 20 hours, so the
# fpath the dumpfile was built from is stamped beside it.
@test "the fpath stamp is written next to the dumpfile" {
  zephyr_plugin completion <<'EOS'
zstyle ':zephyr:plugin:completion' use-cache yes
wanted="$fpath"
run_compinit
print "stamped: $([[ -s $ZSH_COMPDUMP.fpath ]] && print yes || print no)"
print "matches: $([[ "$(<$ZSH_COMPDUMP.fpath)" == "$wanted" ]] && print yes || print no)"
EOS
  assert_success
  assert_line "stamped: yes"
  assert_line "matches: yes"
}

# Rebuilds are detected with a sentinel comment appended to the dumpfile: it
# survives a reuse and is gone after a regeneration. mtime is only second-accurate
# and Linux reuses the inode of a file just removed, so neither works here.
#
# Checked across shells, which is how the cache is actually used: one compinit per
# startup, each snapshotting $fpath before compinit prunes it. Repeated calls inside
# one shell are not a real scenario, and cannot work on Debian, where compinit does
# not hand $fpath back byte-identical.
@test "an unchanged fpath reuses the cache on the next shell, a changed one rebuilds" {
  write_file "$TEST_HOME/warm.zsh" \
    'zstyle ":zephyr:plugin:completion" use-cache yes' \
    '[[ -n $EXTRA ]] && fpath=($EXTRA $fpath)' \
    'source $ZEPHYR_HOME/lib/bootstrap.zsh' \
    'source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh' \
    'run_compinit'
  zephyr_plugin completion <<'EOS'
dump=$XDG_CACHE_HOME/zsh/zcompdump
zsh -f $HOME/warm.zsh
print '# SENTINEL' >>$dump

zsh -f $HOME/warm.zsh
print "reused next shell: $([[ "$(<$dump)" == *SENTINEL* ]] && print yes || print no)"

mkdir -p $HOME/newcomps
EXTRA=$HOME/newcomps zsh -f $HOME/warm.zsh
print "rebuilt on fpath change: $([[ "$(<$dump)" == *SENTINEL* ]] && print no || print yes)"

print '# SENTINEL' >>$dump
EXTRA=$HOME/newcomps zsh -f $HOME/warm.zsh
print "settled after change: $([[ "$(<$dump)" == *SENTINEL* ]] && print yes || print no)"
EOS
  assert_success
  assert_line "reused next shell: yes"
  assert_line "rebuilt on fpath change: yes"
  assert_line "settled after change: yes"
}

# Installing a tool drops a completion into a directory already on fpath, so fpath
# does not change and the stamp still matches. Without a staleness check the new
# completion would stay invisible until the 20 hour cache expired.
#
# Across shells, like its neighbour above: compinit -i prunes insecure directories out
# of $fpath, so a second run_compinit in the same shell never matches the stamp.
@test "a completion added to a directory already on fpath rebuilds the dumpfile" {
  mkdir -p "$TEST_HOME/comps"
  write_file "$TEST_HOME/warm.zsh" \
    'zstyle ":zephyr:plugin:completion" use-cache yes' \
    'fpath=($HOME/comps $fpath)' \
    'source $ZEPHYR_HOME/lib/bootstrap.zsh' \
    'source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh' \
    'run_compinit'
  zephyr_plugin completion <<'EOS'
dump=$XDG_CACHE_HOME/zsh/zcompdump
zsh -f $HOME/warm.zsh >/dev/null
print '# SENTINEL' >>$dump

zsh -f $HOME/warm.zsh >/dev/null
print "unchanged reuses: $([[ "$(<$dump)" == *SENTINEL* ]] && print yes || print no)"

# A tool installs its completion into a directory that is already on fpath.
print '#compdef newtool' >$HOME/comps/_newtool
zsh -f $HOME/warm.zsh >/dev/null
print "rebuilt after install: $([[ "$(<$dump)" == *SENTINEL* ]] && print no || print yes)"
EOS
  assert_success
  assert_line "unchanged reuses: yes"
  assert_line "rebuilt after install: yes"
}

@test "run_compinit -f forces a rebuild" {
  zephyr_plugin completion <<'EOS'
zstyle ':zephyr:plugin:completion' use-cache yes
run_compinit
print '# SENTINEL' >>$ZSH_COMPDUMP
run_compinit -f
print "rebuilt: $([[ "$(<$ZSH_COMPDUMP)" == *SENTINEL* ]] && print no || print yes)"
EOS
  assert_success
  assert_line "rebuilt: yes"
}

#
# compaudit reporting. compinit -i skips insecure directories silently, so the
# plugin says what was dropped afterwards instead.
#

@test "an insecure completion directory is reported" {
  mkdir -p "$TEST_HOME/insecure"
  chmod g+w "$TEST_HOME/insecure"
  zephyr_plugin completion <<'EOS'
fpath=($HOME/insecure $fpath)
zephyr-compaudit-warn
EOS
  assert_success
  assert_output_contains "ignoring insecure completion directories"
  assert_output_contains "insecure"
  assert_output_contains "compaudit | xargs chmod g-w,o-w"
}

# fpath is replaced with one directory we know the permissions of. The host's own
# fpath is not usable here: Debian ships /usr/share/zsh group-writable, so compaudit
# has something to report before the test adds anything.
@test "a clean fpath reports nothing" {
  mkdir -p "$TEST_HOME/clean"
  chmod g-w,o-w "$TEST_HOME/clean" "$TEST_HOME"
  zephyr_plugin completion <<'EOS'
fpath=($HOME/clean)
zephyr-compaudit-warn
print "exit: $?"
EOS
  assert_success
  assert_line "exit: 0"
  refute_output_contains "ignoring insecure"
}

# compaudit is the expensive half of a cold compinit, so a cached startup must not
# run it again just to report what it already knows. The stub counts calls, and
# returning non-zero keeps compinit on the same path it would have taken anyway.
@test "a cached startup does not run compaudit again" {
  zephyr_plugin completion <<'EOS'
zstyle ':zephyr:plugin:completion' use-cache yes
tally=$XDG_CACHE_HOME/audits
: >$tally
functions[compaudit]='print x >>'$tally'; return 1'

run_compinit                 # cold: builds the dump, audits
wait 2>/dev/null
print "cold audits: $(wc -l <$tally | tr -d ' ')"

: >$tally
run_compinit                 # warm: -C fast path, must not audit
wait 2>/dev/null
print "warm audits: $(wc -l <$tally | tr -d ' ')"
EOS
  assert_success
  assert_line "cold audits: 1"
  assert_line "warm audits: 0"
}

@test "the compaudit quiet zstyle is honored" {
  zephyr_plugin completion <<'EOS'
zstyle ':zephyr:plugin:completion:compaudit' quiet yes
zstyle -t ':zephyr:plugin:completion:compaudit' quiet && print "quiet: yes" || print "quiet: no"
EOS
  assert_success
  assert_line "quiet: yes"
}

@test "the compstyle zstyle none skips styling" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:completion' compstyle none
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh
zstyle -g reply ':completion:*' completer 2>/dev/null
print "completer: ${reply:-unset}"
EOS
  assert_success
  assert_line "completer: unset"
}
