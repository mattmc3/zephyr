# completion

> Load and initialize the built-in zsh completion system.

## Options

This plugin sets the following Zsh options:

| action   | option                     | description                                                  |
| -------- | -------------------------- | ------------------------------------------------------------ |
| setopt   | [ALWAYS_TO_END][16.2.2]    | Move cursor to the end of a completed word.                  |
| setopt   | [AUTO_LIST][16.2.2]        | Automatically list choices on ambiguous completion.          |
| setopt   | [AUTO_MENU][16.2.2]        | Show completion menu on a successive tab press.              |
| setopt   | [AUTO_PARAM_SLASH][16.2.2] | If completed parameter is a directory, add a trailing slash. |
| setopt   | [COMPLETE_IN_WORD][16.2.2] | Complete from both ends of a word.                           |
| setopt   | [PATH_DIRS][16.2.2]        | Perform path search even on command names with slashes.      |
| unsetopt | [FLOW_CONTROL][16.2.6]     | Disable start/stop characters in shell editor.               |
| unsetopt | [MENU_COMPLETE][16.2.2]    | Do not autoselect the first completion entry.                |

## Functions

This plugin adds the following functions:

| function          | description                                                  |
| ----------------- | ------------------------------------------------------------ |
| `run_compinit`    | Initialize the Zsh completion system, with optional caching. |
| `run_compinit -f` | Force a cache reset and reinitialize completions.            |

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets the following variables:

| variable       | description                                  |
| -------------- | -------------------------------------------- |
| `ZSH_COMPDUMP` | Path to the zcompdump completion cache file. |

## Customizations

To cache compinit results (regenerated at most once per day):

`zstyle ':zephyr:plugin:completion' 'use-cache' 'yes'`

To allow insecure directories in fpath without warning:

`zstyle ':zephyr:plugin:completion' 'disable-compfix' 'yes'`

To run compinit immediately instead of deferring until after `.zshrc`:

`zstyle ':zephyr:plugin:completion' 'immediate' 'yes'`

To store `ZSH_COMPDUMP` in the XDG cache directory:

`zstyle ':zephyr:plugin:completion' 'use-xdg-basedirs' 'yes'`

To set the completion style (default: `zephyr`):

`zstyle ':zephyr:plugin:completion' 'compstyle' 'zephyr'`

[16.2.2]: https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-2
[16.2.6]: https://zsh.sourceforge.io/Doc/Release/Options.html#Input_002fOutput
