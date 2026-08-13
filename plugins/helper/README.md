# helper

> Deprecated. Nothing to load.

The shared functions moved out of this plugin. They now come with Zephyr's bootstrap, so
any plugin has them and there is nothing to add to your plugin list.

The one-line predicates are defined in [lib/bootstrap.zsh](../../lib/bootstrap.zsh):

| function                 | description                                                        |
| ------------------------ | ------------------------------------------------------------------ |
| `is-autoloadable <func>` | Checks if a function can be autoloaded by trying it in a subshell. |
| `is-callable <name>`     | Checks if a name is a command, function, alias, or builtin.        |
| `is-true <value>`        | Checks if a value spells true (1, y, yes, t, true, o, on).         |
| `is-term-family <term>`  | Checks if `$TERM` matches the given terminal family.               |
| `is-tmux`                | Checks if running inside tmux.                                     |
| `is-macos`               | Checks if the OS is macOS.                                         |
| `is-linux`               | Checks if the OS is Linux.                                         |
| `is-bsd`                 | Checks if the OS is BSD.                                           |
| `is-cygwin`              | Checks if the OS is Cygwin.                                        |
| `is-termux`              | Checks if the OS is Termux.                                        |

The two with real bodies are autoloaded from [functions/](../../functions), so they cost
nothing until you call them:

| function                   | description                                                                                                                      |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `cached-eval <cmd> [args]` | Cache the output of a command and source it, refreshing after 20 hours. `--clear` first drops one cache, or all with no command. |
| `gen-uuid7`                | Generate a time-ordered UUID v7 into `$REPLY`.                                                                                   |

`mkdirvar` is gone. It never worked, and nothing used it.

This directory stays so that bundling `path:plugins/helper` keeps working: the plugin
file now just sources the bootstrap.
