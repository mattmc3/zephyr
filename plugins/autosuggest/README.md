# autosuggest

> Suggest commands from history as you type.

Type part of a command and the most recent history entry starting with it is shown
after the cursor, dimmed. Right arrow or Ctrl+E takes all of it, Alt+F takes a word,
and anything else ignores it.

The suggestion lives in `POSTDISPLAY`, not in the line, and is recomputed on every
redraw rather than by wrapping the editing widgets, so widgets added later need no
special care. Needs zsh 5.9 for the `memo=` highlight tag.

Nothing is suggested on an empty line, on a multi-line or `PS2` buffer, in vi command
mode, or during an incremental search.

Works on its own, with no dependency on the rest of Zephyr.

Coexists with `zsh-syntax-highlighting` in either load order. The suggestion highlight
is re-registered at the first prompt so it draws last, and is tagged with a `memo=` so
it only ever removes its own.

Coexists with the `history-search` plugin: Up and Down fill the line themselves and
paint their own match, so the suggestion steps aside while a search is running.

A plugin that resets keymaps after this one loads takes these bindings with it. Load
this plugin after it, or call `autosuggest-bindkeys` once everything is loaded.

## Options

This plugin sets no Zsh options.

## Functions

This plugin adds the following functions:

| function                    | description                                                    |
| --------------------------- | -------------------------------------------------------------- |
| `autosuggest-forward-char`  | Widget: take the suggestion, or move the cursor forward.       |
| `autosuggest-end-of-line`   | Widget: take the suggestion, or move to the end of the line.   |
| `autosuggest-forward-word`  | Widget: take one word of the suggestion, or move a word.       |
| `autosuggest-history`       | The default strategy: newest history entry starting with `$1`. |
| `autosuggest-bindkeys`      | Bind the take keys in the emacs and viins keymaps.             |

The rest are internal, and all share the `autosuggest-` prefix:
`autosuggest-suppressed`, `autosuggest-fetch`, `autosuggest-take`,
`autosuggest-clear`, and `autosuggest-highlight-last`.

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets no variables intended for you to read.

## Customizations

To skip this plugin entirely. Do this if you use another suggestion plugin, such as
zsh-autosuggestions:

`zstyle ':zephyr:plugin:autosuggest' 'skip' 'yes'`

To change how the suggestion is drawn. Takes any `region_highlight` style:

`zstyle ':zephyr:plugin:autosuggest' 'highlight' 'fg=blue'`

To suggest from somewhere other than history, name a function of your own. It gets the
line as `$1` and sets `$suggestion` rather than printing, since a command substitution
on every keypress means a fork on every keypress:

```zsh
function my-suggester {
  suggestion=$(...)  # no: this forks on every keypress
  suggestion=${...}  # yes
}
zstyle ':zephyr:plugin:autosuggest' 'strategy' 'my-suggester'
```

To keep the widgets but bind different keys yourself:

```zsh
zstyle ':zephyr:plugin:autosuggest' 'bindkeys' 'no'
bindkey '^[[C' autosuggest-forward-char
bindkey '^E' autosuggest-end-of-line
```
