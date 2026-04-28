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

## Auxiliary history

The aux history feature records every command to a structured file alongside the standard `HISTFILE`. Each record includes the session ID, working directory, command, exit status, per-pipe exit statuses, and timestamps. SQLite and JSONL backends are available independently and can run simultaneously.

Enable one or both backends:

```zsh
zstyle ':zephyr:plugin:history:aux:sqlite' enable yes
zstyle ':zephyr:plugin:history:aux:json'   enable yes
```

Override the default file paths (optional):

```zsh
zstyle ':zephyr:plugin:history:aux:sqlite' histfile ~/.local/share/zsh/history.db
zstyle ':zephyr:plugin:history:aux:json'   histfile ~/.local/share/zsh/history.json
```

Default paths (XDG-aware):

| backend | default path                          |
| ------- | ------------------------------------- |
| sqlite  | `$XDG_DATA_HOME/zsh/zsh_history.db`   |
| json    | `$XDG_DATA_HOME/zsh/zsh_history.json` |

**Dependencies:** the sqlite backend requires `sqlite3`; the json backend requires `jq`.

Each record contains:

| field        | type    | description                                          |
| ------------ | ------- | ---------------------------------------------------- |
| `sid`        | text    | UUID v7 session identifier                           |
| `cwd`        | text    | Current working directory the command ran in         |
| `cmd`        | text    | The command being run                                |
| `ret`        | integer | Exit status of the command                           |
| `pipestatus` | text    | Comma-separated exit statuses of each pipeline stage |
| `start_ts`   | real    | Unix timestamp (fractional) when command started     |
| `end_ts`     | real    | Unix timestamp (fractional) when command ended       |

### Querying

**JSONL**: sample of recent commands with local time and duration:

```sh
jq -r '[(.start_ts | strflocaltime("%Y-%m-%d %H:%M:%S")),
        ((.end_ts - .start_ts) * 1000 | round / 1000 | tostring) + "s",
        (.ret | tostring),
        (.cmd | if length > 25 then .[:25] + "…" else . end)] | @tsv' \
    ~/.local/share/zsh/zsh_history.json | tail -20
```

**SQLite**: sample of recent commands with local time and duration:

```sh
sqlite3 -column -header ~/.local/share/zsh/zsh_history.db "
  SELECT datetime(start_ts, 'unixepoch', 'localtime') AS started,
         round(end_ts - start_ts, 3) || 's' AS duration,
         ret, iif(length(cmd) > 25, substr(cmd, 1, 25) || '…', cmd) AS cmd
  FROM   zsh_history
  ORDER  BY start_ts DESC
  LIMIT  20;"
```

**SQLite**: export as JSONL in the same format as the json backend:

```sh
sqlite3 ~/.local/share/zsh/zsh_history.db \
  "SELECT json_object('sid',sid,'cwd',cwd,'cmd',cmd,'ret',ret,
                      'pipestatus',pipestatus,'start_ts',start_ts,'end_ts',end_ts)
   FROM zsh_history ORDER BY start_ts;"
```

[16.2.4]: https://zsh.sourceforge.io/Doc/Release/Options.html#History
