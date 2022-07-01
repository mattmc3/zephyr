# Editor

Sets editor specific key bindings options and variables.

## Options

- `NO_BEEP` on error in line editor.
- `FLOW_CONTROL` allow the usage of ^Q/^S in the context of zsh.

## Variables

- `EDITOR` text editor.
- `VISUAL` visual text editor.
- `PAGER` pager for long text.
- `WORDCHARS` treat a given set of characters as part of a word.
- `READNULLCMD` use `< file` to quickly view the contents of any file.

## Convenience Functions

### bindkey-all

Provides a function `bindkey-all` which can be useful for checking how all of
the keys are bound. Normal `bindkey` command will only list the keys bound for
one keymap, which is not as useful if you want to grep through the output. The
keymap's names go to stderr so when you grep through `bindkey-all`'s output you
will still see the headings and can tell which keymap each binding goes to.

It will also pass through arguments so you can use bindkey-all to set bindings
for all keymaps at once. If provided arguments it will _not_ print out the
names of each of the keymaps, and just run the command for each keymap.

## Authors

_The authors of this module should be contacted via the [issue tracker][1]._

- [Sorin Ionescu](https://github.com/sorin-ionescu)

[1]: https://github.com/sorin-ionescu/prezto/issues
