#!/bin/zsh
#
# .zstyles - Set zstyle options for Zephyr and other plugins/features.
#

#
# General
#

# Set case-sensitivity for completion, history lookup, etc.
# zstyle ':zephyr:*:*' case-sensitive 'yes'

# Color output (auto set to 'no' on dumb terminals).
zstyle ':zephyr:*:*' color 'yes'

# Set the Zephyr plugins to load (browse plugins).
# The order matters.
zstyle ':zephyr:load' plugins \
  'environment' \
  'editor' \
  'history' \
  'directory' \
  'color' \
  'utility' \
  'completion' \
  'prompt'

#
# Completions
#

# Set the entries to ignore in static '/etc/hosts' for host completion.
# zstyle ':zephyr:plugin:completion:*:hosts' etc-host-ignores \
#   '0.0.0.0' '127.0.0.1'

# Set the preferred completion style.
# zstyle ':zephyr:plugin:completion' compstyle 'zephyr'

#
# Directory
#

# Don't set directory aliases.
# zstyle ':zephyr:plugin:directory:alias' skip 'yes'

#
# Editor
#

# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':zephyr:plugin:editor' key-bindings 'emacs'

# Don't auto convert .... to ../..
# zstyle ':zephyr:plugin:editor' dot-expansion 'no'

# Allow the zsh prompt context to be shown.
# zstyle ':zephyr:plugin:editor' ps-context 'yes'

# Set the default (magic) command when hitting enter on an empty prompt.
# zstyle ':zephyr:plugin:editor' default-command 'ls -lh .'
# zstyle ':zephyr:plugin:editor' default-git-command 'git status -u .'

#
# History
#

# Set the file to save the history in when an interactive shell exits.
# zstyle ':zephyr:plugin:history' histfile "${ZDOTDIR:-$HOME}/.zsh_history"

# Set the maximum number of events stored in the internal history list.
# zstyle ':zephyr:plugin:history' histsize 10000

# Set the maximum number of history events to save in the history file.
# zstyle ':zephyr:plugin:history' savehist 10000

# Don't set history aliases.
# zstyle ':zephyr:plugin:history:alias' skip 'yes'

#
# Prompt
#

# Set the prompt theme to load.
# starship themes: zephyr, hydro, prezto
zstyle ':zephyr:plugin:prompt' theme starship zephyr

#
# Terminal
#

# Auto set the tab and window titles.
# zstyle ':zephyr:plugin:terminal' auto-title 'yes'

# Set the window title format.
# zstyle ':zephyr:plugin:terminal:window-title' format '%n@%m: %s'

# Set the tab title format.
# zstyle ':zephyr:plugin:terminal:tab-title' format '%m: %s'

# Set the terminal multiplexer title format.
# zstyle ':zephyr:plugin:terminal:multiplexer-title' format '%s'
