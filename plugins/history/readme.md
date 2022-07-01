# History

Sets [history][1] options and defines history aliases.

## Options

- `APPEND_HISTORY` append to history file.
- `HIST_NO_STORE` don't store history commands.
- `HIST_REDUCE_BLANKS` remove superfluous blanks from each command line being added to the history list.
- `BANG_HIST` treats the **!** character specially during expansion.
- `EXTENDED_HISTORY` writes the history file in the _:start:elapsed;command_
  format.
- `NO_SHARE_HISTORY` don't share history between all sessions.
  Note that `SHARE_HISTORY`, `INC_APPEND_HISTORY`, and `INC_APPEND_HISTORY_TIME`
  are mutually exclusive.
- `INC_APPEND_HISTORY` zsh sessions will append their history list to the history file
  rather than replace it.
  Note that `SHARE_HISTORY`, `INC_APPEND_HISTORY`, and `INC_APPEND_HISTORY_TIME`
  are mutually exclusive.
- `HIST_EXPIRE_DUPS_FIRST` expires a duplicate event first when trimming history.
- `HIST_IGNORE_DUPS` does not record an event that was just recorded again.
- `HIST_IGNORE_ALL_DUPS` deletes an old recorded event if a new event is a
  duplicate.
- `HIST_FIND_NO_DUPS` does not display a previously found event.
- `HIST_IGNORE_SPACE` does not record an event starting with a space.
- `HIST_SAVE_NO_DUPS` does not write a duplicate event to the history file.
- `HIST_VERIFY` does not execute immediately upon history expansion.
- `NO_HIST_BEEP` don't beep when accessing non-existent history.

## Variables

- `HISTFILE` stores the path to the history file.
- `HISTSIZE` stores the maximum number of events to save in the internal history.
- `SAVEHIST` stores the maximum number of events to save in the history file.

## Aliases

- `history-stat` lists the ten most used commands

## Settings

### histfile

Can be configured by setting `HISTFILE` manually before loading this plugin

```sh
HISTFILE=~/.zhistory
```

defaults to "~/.local/share/zsh/history".

### histsize

```sh
HISTSIZE=15000
```

defaults to 20000.

### savehist

```sh
SAVEHIST=15000
```

defaults to 10000.

[1]: https://zsh.sourceforge.io/Doc/Release/Options.html#History
