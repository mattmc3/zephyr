# editor

Zsh line editor configuration and keybindings.

## Features

**Ctrl-Z** - Push current command to background, or bring back with Ctrl-Z on empty line (enabled by default)

**Ctrl-X Ctrl-S** - Add `sudo` to the beginning of the line (enabled by default)

**Ctrl-X Ctrl-E** - Edit the current command in `$EDITOR` (enabled by default)

**Ctrl-X Ctrl-X** - Complete the word under the cursor from history (enabled by default)

**Ctrl-X Ctrl-C** - Copy the current command to the clipboard (enabled by default)

**Ctrl-Space** - Expand aliases (enabled by default)

**Space** - Expand aliases automatically as you type (disabled by default)

**Dot expansion** - Type `...` to expand to `../..`, `....` to `../../..`, etc (disabled by default)

**Magic enter** - Press enter on empty line to run `ls` or `git status` if in a git repo (disabled by default)

**Accept line or newline** - Press enter on an unfinished command to open a new line
instead of dropping to a `PS2` prompt (disabled by default)

## Functions

This plugin adds the following functions:

| function                        | description                                                            |
| ------------------------------- | ---------------------------------------------------------------------- |
| `bindkey-all <args>`            | Run `bindkey` against every keymap.                                    |
| `bindkey-multiple [-M <keymap>] <widget> <seq>...` | Bind one widget to several key sequences, skipping empty ones. |
| `add-accept-line-hook [-d] <fn>...` | Attach a function to run when Enter accepts a line, or detach it with `-d`. |
| `command-is-complete <string>`  | True when the string is a command ready to run, without running it.    |

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets the following variables:

| variable            | description                                              |
| ------------------- | -------------------------------------------------------- |
| `WORDCHARS`         | Characters treated as part of a word.                    |
| `key_info`          | Human-friendly names for terminal key sequences.         |
| `accept_line_hook`  | Functions to run when Enter accepts a line.              |

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

Set custom magic-enter commands. The `jj-command` only applies inside a jj repo, and
beats `git-command` in a colocated one:

```zsh
zstyle ':zephyr:plugin:editor:magic-enter' command 'ls -la'
zstyle ':zephyr:plugin:editor:magic-enter' git-command 'git status'
zstyle ':zephyr:plugin:editor:magic-enter' jj-command 'jj st'
```

Force alias expansion on, or off, for specific words. A global alias always expands,
and a plain alias only expands when it isn't also a command name, so `ls='ls --color'`
is left alone:

```zsh
zstyle ':zephyr:plugin:editor:glob-alias' noexpand 'ls' 'rm'
zstyle ':zephyr:plugin:editor:glob-alias' expand 'vim' 'cat'
```

Set the cursor style per keymap. Styles are `block`, `underscore`, and `line`, each
also with a `-blink` suffix:

```zsh
zstyle ':zephyr:plugin:editor:vicmd' cursor 'block'
zstyle ':zephyr:plugin:editor:viins' cursor 'line'
zstyle ':zephyr:plugin:editor:emacs' cursor 'underscore'
```
