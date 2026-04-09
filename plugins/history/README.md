# history

> Set history options and define history aliases.

## Options

This plugin sets the following Zsh options:

| action   | option                           | description                                                      |
| -------- | -------------------------------- | ---------------------------------------------------------------- |
| setopt   | [BANG_HIST][16.2.4]              | Treat `!` specially during expansion.                            |
| setopt   | [EXTENDED_HISTORY][16.2.4]       | Write history in the `:start:elapsed;command` format.            |
| setopt   | [HIST_EXPIRE_DUPS_FIRST][16.2.4] | Expire duplicate events first when trimming history.             |
| setopt   | [HIST_FIND_NO_DUPS][16.2.4]      | Do not display a previously found event.                         |
| setopt   | [HIST_IGNORE_ALL_DUPS][16.2.4]   | Delete an old recorded event if a new event is a duplicate.      |
| setopt   | [HIST_IGNORE_DUPS][16.2.4]       | Do not record an event that was just recorded again.             |
| setopt   | [HIST_IGNORE_SPACE][16.2.4]      | Do not record an event starting with a space.                    |
| setopt   | [HIST_REDUCE_BLANKS][16.2.4]     | Remove extra blanks from commands added to the history list.     |
| setopt   | [HIST_SAVE_NO_DUPS][16.2.4]      | Do not write a duplicate event to the history file.              |
| setopt   | [HIST_VERIFY][16.2.4]            | Do not execute immediately upon history expansion.               |
| setopt   | [INC_APPEND_HISTORY][16.2.4]     | Write to the history file immediately, not when the shell exits. |
| unsetopt | [HIST_BEEP][16.2.4]              | Don't beep when accessing non-existent history.                  |
| unsetopt | [SHARE_HISTORY][16.2.4]          | Don't share history between all sessions.                        |

## Functions

This plugin sets no functions.

## Aliases

This plugin adds the following aliases:

| alias          | description                                    |
| -------------- | ---------------------------------------------- |
| `hist`         | `fc -li`: show history with timestamps         |
| `history-stat` | Show the most frequently used history commands |

## Variables

This plugin sets the following variables:

| variable   | description                                                     |
| ---------- | --------------------------------------------------------------- |
| `HISTFILE` | Path to the history file (default: `~/.zsh_history`)            |
| `SAVEHIST` | Number of events to save to the history file (default: 100000)  |
| `HISTSIZE` | Number of events to keep in memory per session (default: 20000) |

## Customizations

To set a custom history file path:

`zstyle ':zephyr:plugin:history' 'histfile' '/path/to/history'`

To set custom history file size:

`zstyle ':zephyr:plugin:history' 'savehist' '50000'`

To set custom session history size:

`zstyle ':zephyr:plugin:history' 'histsize' '10000'`

To store the history file in the XDG data directory:

`zstyle ':zephyr:plugin:history' 'use-xdg-basedirs' 'yes'`

To skip setting history aliases:

`zstyle ':zephyr:plugin:history:alias' 'skip' 'yes'`

[16.2.4]: https://zsh.sourceforge.io/Doc/Release/Options.html#History
