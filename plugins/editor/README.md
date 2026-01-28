# editor

Zsh line editor configuration and keybindings.

## Features

**Ctrl-Z** - Push current command to background, or bring back with Ctrl-Z on empty line (enabled by default)

**Ctrl-X Ctrl-S** - Add `sudo` to the beginning of the line (enabled by default)

**Ctrl-Space** - Expand aliases (enabled by default)

**Space** - Expand aliases automatically as you type (disabled by default)

**Dot expansion** - Type `...` to expand to `../..`, `....` to `../../..`, etc (disabled by default)

**Magic enter** - Press enter on empty line to run `ls` or `git status` if in a git repo (disabled by default)

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
```

Set custom magic-enter commands:

```zsh
zstyle ':zephyr:plugin:editor:magic-enter' command 'ls -la'
zstyle ':zephyr:plugin:editor:magic-enter' git-command 'git status'
```
