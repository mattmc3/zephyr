# history-search

> Search history from Up and Down using what's already typed.

Type part of a command and press Up. The line is matched as a substring against
history, newest first, and Up keeps walking back through matches while Down walks
forward. Past the newest match, the line you typed comes back.

On a multi-line command, Up and Down move between the lines instead, and a
half-typed `PS2` construct is pulled into one buffer first so the whole thing can be
edited at once.

Works on its own, with no dependency on the rest of Zephyr.

Coexists with `zsh-syntax-highlighting` in either load order. The match highlight is
re-registered at the first prompt so it draws last, and is tagged with a `memo=` so it
only ever removes its own.

A plugin that resets keymaps after this one loads takes these bindings with it. Load
this plugin after it, or call `history-search-bindkeys` once everything is loaded.

## Options

This plugin sets no Zsh options.

## Functions

This plugin adds the following functions:

| function                        | description                                                     |
| ------------------------------- | --------------------------------------------------------------- |
| `up-line-or-history-search`     | Widget: search back, or move up a line in a multi-line command. |
| `down-line-or-history-search`   | Widget: search forward, or move down a line.                    |
| `history-search-bindkeys`       | Bind Up and Down in the emacs, viins, and vicmd keymaps.        |

The rest are internal, and all share the `history-search-` prefix:
`history-search-in-progress`, `history-search-step`,
`history-search-pull-prebuffer`, `history-search-highlight`, and
`history-search-highlight-last`.

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets no variables intended for you to read.

## Customizations

To skip this plugin entirely, leaving Up and Down at their Zsh defaults. Do this if
you use another history search plugin, such as zsh-history-substring-search:

`zstyle ':zephyr:plugin:history-search' 'skip' 'yes'`

To change how the matched text is highlighted (needs zsh 5.9). Takes any
`region_highlight` style:

`zstyle ':zephyr:plugin:history-search' 'highlight' 'fg=black,bg=cyan'`

To keep the widgets but bind different keys yourself:

```zsh
zstyle ':zephyr:plugin:history-search' 'bindkeys' 'no'
bindkey '^P' up-line-or-history-search
bindkey '^N' down-line-or-history-search
```
