# Environment

Sets general shell options and defines environment variables.

## Options

### General

I/O [options][1] and Zle [options][2]:
- `COMBINING_CHARS` combine zero-length punctuation characters (accents) with
  the base character.
- `INTERACTIVE_COMMENTS` enable comments in interactive shell.
- `RC_QUOTES` allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
- `NO_MAIL_WARNING` don't print a warning message if a mail file has been accessed.

### Globbing

Expansion and globbing [options][3]:
- `EXTENDED_GLOB` Treat the '#', '~' and '^' characters as part of patterns for filename generation
- `GLOB_DOTS` Do not require a leading '.' in a filename to be matched explicitly

### Jobs

Job control [options][4]:
- `LONG_LIST_JOBS` list jobs in the long format by default.
- `AUTO_RESUME` attempt to resume existing job before creating a new process.
- `NOTIFY` report status of background jobs immediately.
- `NO_BG_NICE` don't run all background jobs at a lower priority.
- `NO_HUP` don't kill jobs on shell exit.
- `NO_CHECK_JOBS` don't report on jobs when shell exit.

## Variables

XDG base directory [variables][5]:
- `XDG_CONFIG_HOME` config location
- `XDG_CACHE_HOME` cache location
- `XDG_DATA_HOME` data location
- `XDG_RUNTIME_DIR` runtime location


[1]:  https://zsh.sourceforge.io/Doc/Release/Options.html#Input_002fOutput
[2]:  https://zsh.sourceforge.io/Doc/Release/Options.html#Zle
[3]:  https://zsh.sourceforge.io/Doc/Release/Options.html#Expansion-and-Globbing
[4]:  https://zsh.sourceforge.io/Doc/Release/Options.html#Job-Control
[5]:  https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
