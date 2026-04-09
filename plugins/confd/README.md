# confd

> Source a Fish-like conf.d directory.

## Description

Sources all `.sh` and `.zsh` files from a `conf.d` directory after `.zshrc` loads.
Files are sourced in alphabetical order. Files with a name beginning with `~` are ignored.

The default directory is searched in this order:

1. `$ZDOTDIR/conf.d`
2. `$ZDOTDIR/zshrc.d`
3. `$ZDOTDIR/rc.d`
4. `$HOME/.zshrc.d`

## Options

This plugin sets no Zsh options.

## Functions

This plugin adds the following functions:

| function    | description                                 |
| ----------- | ------------------------------------------- |
| `run_confd` | Source all scripts in the conf.d directory. |

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets no variables.

## Customizations

To set a custom conf.d directory:

`zstyle ':zephyr:plugin:confd' 'directory' '/path/to/conf.d'`

To source the conf.d directory immediately instead of deferring until after `.zshrc`:

`zstyle ':zephyr:plugin:confd' 'immediate' 'yes'`
