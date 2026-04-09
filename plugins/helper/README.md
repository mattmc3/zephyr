# Helper

> Add common helper functions.

## Options

This plugin sets no Zsh options.

## Functions

This plugin adds the following functions:

| function                   | description                                                                        |
| -------------------------- | ---------------------------------------------------------------------------------- |
| `cached-eval <name> <cmd>` | Cache the output of a command and source it, refreshing after 20 hours.            |
| `mkdirvar <varname>`       | Create a directory from the value of a variable name.                              |
| `is-autoloadable <func>`   | Checks if a function can be autoloaded by trying to load it in a subshell.         |
| `is-callable <name>`       | Checks if a name is a command, function, or alias.                                 |
| `is-true <value>`          | Checks if a value is a string representation of true (eg: 1, yes, y, t, on, etc.). |
| `is-term-family <term>`    | Checks if `$TERM` matches the given terminal family.                               |
| `is-tmux`                  | Checks if running inside tmux.                                                     |
| `is-macos`                 | Checks if the OS is macOS.                                                         |
| `is-linux`                 | Checks if the OS is Linux.                                                         |
| `is-bsd`                   | Checks if the OS is BSD.                                                           |
| `is-cygwin`                | Checks if the OS is Cygwin.                                                        |
| `is-termux`                | Checks if the OS is Android/Termux.                                                |

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets no variables.

## Customizations

This plugin does not have any zstyles for customization.
