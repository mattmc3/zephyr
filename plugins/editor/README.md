# editor

Zsh line editor configuration and keybindings.

## Features

**Ctrl-Z** - Resume the job you suspended with Ctrl-Z, so the same key sends a job away
and brings it back. Anything half-typed is stashed and returns when the job stops
again, `fg` stays out of your history, and with no job to resume the line is left
alone (enabled by default)

**Home / End** - Go to the ends of the current line, and to the ends of the whole
buffer when already there (enabled by default)

**Ctrl-X Ctrl-S** - Add `sudo` to the beginning of the line (enabled by default)

**Ctrl-X Ctrl-E** - Edit the current command in `$EDITOR` (enabled by default)

**Ctrl-X Ctrl-X** - Complete the word under the cursor from history (enabled by default)

**Ctrl-X Ctrl-C** - Copy the current command to the clipboard (enabled by default)

**Ctrl-Space** - Expand aliases (enabled by default)

**Space** - Expand aliases automatically as you type (disabled by default)

**Dot expansion** - Type `...` to expand to `../..`, `....` to `../../..`, etc (disabled
by default)

**Magic enter** - Press enter on empty line to run `ls` or `git status` if in a git repo
(disabled by default)

**Accept line or newline** - Press enter on an unfinished command to open a new line
instead of dropping to a `PS2` prompt (disabled by default)

## Functions

This plugin adds the following functions:

| function                                           | description                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------- |
| `bindkey-all <args>`                               | Run `bindkey` against every keymap.                                 |
| `bindkey-multiple [-M <keymap>] <widget> <seq>...` | Bind one widget to several key sequences, skipping empty ones.      |
| `command-is-complete <string>`                     | True when the string is a command ready to run, without running it. |

This plugin runs the functions in `$accept_line_hook` when Enter accepts a line. Add one
with `add-accept-line-hook`, which comes from `lib/bootstrap.zsh` so it works whether or
not this plugin has loaded:

```zsh
function my-hook { print -s "$BUFFER" }
add-accept-line-hook my-hook
add-accept-line-hook -d my-hook   # detach
```

Hooks run in the order added, inside the widget, so `BUFFER`, `CURSOR` and `zle` all
work normally. A hook whose function no longer exists is skipped.

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets the following variables:

| variable           | description                                      |
| ------------------ | ------------------------------------------------ |
| `WORDCHARS`        | Characters treated as part of a word.            |
| `key_info`         | Human-friendly names for terminal key sequences. |
| `accept_line_hook` | Functions to run when Enter accepts a line.      |

## Configuration

Disable a feature:

```zsh
zstyle ':zephyr:plugin:editor' symmetric-ctrl-z no
zstyle ':zephyr:plugin:editor' prepend-sudo no
zstyle ':zephyr:plugin:editor' glob-alias no
```

Enable a feature:

```zsh
zstyle ':zephyr:plugin:editor' dot-expansion yes
zstyle ':zephyr:plugin:editor' magic-enter yes
zstyle ':zephyr:plugin:editor' automatic-glob-alias yes
zstyle ':zephyr:plugin:editor' accept-line-or-newline yes
```

Set the key layout - `emacs`, `vi`, or `existing` (default: `emacs`):

```zsh
zstyle ':zephyr:plugin:editor' key-bindings 'existing'
```

`existing` keeps whatever keymap is already linked to `main`. Use it if you set
`bindkey -v` yourself, or load a plugin like zsh-vi-mode.

Reset all keymaps to Zsh defaults before binding (default: no):

```zsh
zstyle ':zephyr:plugin:editor' reset-keymaps 'yes'
```

This discards keybindings set before Zephyr loads, and deletes keymaps made with
`bindkey -N`. Skipped under `zsh-defer`, where it segfaults Zsh ([#40]).

[#40]: https://github.com/mattmc3/zephyr/issues/40

Set custom magic-enter commands. The `jj-command` only applies inside a jj repo, and
beats `git-command` in a colocated one:

```zsh
zstyle ':zephyr:plugin:editor:magic-enter' command 'ls -la'
zstyle ':zephyr:plugin:editor:magic-enter' git-command 'git status'
zstyle ':zephyr:plugin:editor:magic-enter' jj-command 'jj st'
```

Force alias expansion on, or off, for specific words. A global alias always expands, and
a plain alias only expands when it isn't also a command name, so `ls='ls --color'` is
left alone:

```zsh
zstyle ':zephyr:plugin:editor:glob-alias' noexpand 'ls' 'rm'
zstyle ':zephyr:plugin:editor:glob-alias' expand 'vim' 'cat'
```

Also expand the alias when you press Enter, not just the expansion key (default: no).
This rewrites the line before it runs:

```zsh
zstyle ':zephyr:plugin:editor:glob-alias' on-accept 'yes'
```

Set the cursor style per keymap. Styles are `block`, `underscore`, and `line`, each also
with a `-blink` suffix:

```zsh
zstyle ':zephyr:plugin:editor:vicmd' cursor 'block'
zstyle ':zephyr:plugin:editor:viins' cursor 'line'
zstyle ':zephyr:plugin:editor:emacs' cursor 'underscore'
```
