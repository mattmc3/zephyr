#!/usr/bin/env bats
# The prompt system wrapper.

load helpers/common

setup() { zephyr_setup; }
teardown() { zephyr_teardown; }

@test "prompt_subst is on and PS2 indents by level" {
  zephyr_plugin prompt <<'EOS'
print "promptsubst: $([[ -o prompt_subst ]] && print on || print off)"
print "ps2: ${(q)PS2}"
EOS
  assert_success
  assert_line "promptsubst: on"
  assert_output_contains '${${${(%):-%_}//[^ ]}// /  }'
}

@test "promptinit and run_promptinit are wrapped" {
  zephyr_plugin prompt <<'EOS'
print "promptinit: $+functions[promptinit]"
print "run_promptinit: $+functions[run_promptinit]"
print "starship setup: $+functions[prompt_starship_setup]"
print "p10k setup: $+functions[prompt_p10k_setup]"
EOS
  assert_success
  assert_line "promptinit: 1"
  assert_line "run_promptinit: 1"
  assert_line "starship setup: 1"
  assert_line "p10k setup: 1"
}

@test "a user themes directory joins fpath and its themes register" {
  write_file "$TEST_HOME/.config/zsh/themes/prompt_mytheme_setup" 'PS1="mytheme> "'
  zephyr_plugin prompt <<'EOS'
local -a m=(${(M)fpath:#$__zsh_config_dir/themes})
print "in fpath: $#m"
promptinit
local -a t=(${(M)prompt_themes:#mytheme})
print "registered: $#t"
EOS
  assert_success
  assert_line "in fpath: 1"
  assert_line "registered: 1"
}

@test "promptinit is deferred to post_zshrc by default" {
  zephyr_plugin prompt 'print "queued: ${post_zshrc_hook[(r)run_promptinit]:-none}"'
  assert_success
  assert_line "queued: run_promptinit"
}

@test "the immediate zstyle runs promptinit at load time" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:prompt' immediate yes
zstyle ':zephyr:plugin:prompt' theme off
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
print "queued: ${post_zshrc_hook[(r)run_promptinit]:-none}"
print "themes: ${#prompt_themes}"
EOS
  assert_success
  assert_line "queued: none"
}

# Calling the real promptinit takes the deferred hook off the list.
@test "running promptinit early clears the hook" {
  zephyr_plugin prompt <<'EOS'
promptinit
print "queued: ${post_zshrc_hook[(r)run_promptinit]:-none}"
print "themes sorted: $([[ "$prompt_themes" == "${(on)prompt_themes}" ]] && print yes || print no)"
EOS
  assert_success
  assert_line "queued: none"
  assert_line "themes sorted: yes"
}

@test "a dumb terminal turns the prompt off" {
  zephyr_zsh <<'EOS'
export TERM=dumb
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
run_promptinit
print "prompt: ${prompt_theme[1]:-none}"
EOS
  assert_success
  assert_line "prompt: off"
}

@test "the linux console turns the prompt off by default" {
  zephyr_zsh <<'EOS'
export TERM=linux
zstyle ':zephyr:plugin:prompt' theme walters
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
run_promptinit
print "prompt: ${prompt_theme[1]:-none}"
EOS
  assert_success
  assert_line "prompt: off"
}

@test "force keeps the theme in the linux console" {
  zephyr_zsh <<'EOS'
export TERM=linux
zstyle ':zephyr:plugin:prompt' force yes
zstyle ':zephyr:plugin:prompt' theme walters
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
run_promptinit
print "prompt: ${prompt_theme[1]:-none}"
EOS
  assert_success
  assert_line "prompt: walters"
}

@test "a bsd console turns the prompt off by default" {
  zephyr_zsh <<'EOS'
export TERM=netbsd6
zstyle ':zephyr:plugin:prompt' theme walters
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
run_promptinit
print "prompt: ${prompt_theme[1]:-none}"
EOS
  assert_success
  assert_line "prompt: off"
}

# dumb has no zle, so it is off whatever the zstyle says.
@test "a dumb terminal stays off even with force" {
  zephyr_zsh <<'EOS'
export TERM=dumb
zstyle ':zephyr:plugin:prompt' force yes
zstyle ':zephyr:plugin:prompt' theme walters
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
run_promptinit
print "prompt: ${prompt_theme[1]:-none}"
EOS
  assert_success
  assert_line "prompt: off"
}

@test "the theme zstyle picks the prompt" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:prompt' theme off
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
run_promptinit
print "prompt: ${prompt_theme[1]:-none}"
EOS
  assert_success
  assert_line "prompt: off"
}

@test "starship is wired in when the command exists" {
  stub_command starship 'print "# starship init"; print "export STARSHIP_LOADED=1"'
  zephyr_plugin prompt <<'EOS'
promptinit
local -a m=(${(M)prompt_themes:#starship})
print "registered: $#m"
EOS
  assert_success
  assert_line "registered: 1"
}

@test "starship is dropped when the command is missing" {
  zephyr_zsh <<'EOS'
path=(/usr/bin /bin); rehash
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
promptinit
local -a m=(${(M)prompt_themes:#starship})
print "registered: $#m"
print "setup: $+functions[prompt_starship_setup]"
EOS
  assert_success
  assert_line "registered: 0"
  assert_line "setup: 0"
}

@test "the starship cache zstyle routes init through cached-eval" {
  stub_command starship 'print "export STARSHIP_LOADED=1"'
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:prompt' use-cache yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
prompt_starship_setup
print "loaded: $STARSHIP_LOADED"
print "cached: $(ls $XDG_CACHE_HOME/zsh/cached-eval | wc -l | tr -d ' ')"
EOS
  assert_success
  assert_line "loaded: 1"
  assert_line "cached: 1"
}

@test "the skip zstyle keeps the plugin out entirely" {
  zephyr_zsh <<'EOS'
zstyle ':zephyr:plugin:prompt' skip yes
source $ZEPHYR_HOME/lib/bootstrap.zsh
source $ZEPHYR_HOME/plugins/prompt/prompt.plugin.zsh
print "run_promptinit: $+functions[run_promptinit]"
EOS
  assert_success
  assert_line "run_promptinit: 0"
}
