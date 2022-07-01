# Environment

Sets general shell options and defines environment variables.

## Options

### General

- `COMBINING_CHARS` combine zero-length punctuation characters (accents) with
  the base character.
- `INTERACTIVE_COMMENTS` enable comments in interactive shell.
- `RC_QUOTES` allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
- `MAIL_WARNING` don't print a warning message if a mail file has been accessed.

### Globbing
- `EXTENDED_GLOB` Treat the '#', '~' and '^' characters as part of patterns for filename generation
- `GLOB_DOTS` Do not require a leading '.' in a filename to be matched explicitly

### Jobs

- `LONG_LIST_JOBS` list jobs in the long format by default.
- `AUTO_RESUME` attempt to resume existing job before creating a new process.
- `NOTIFY` report status of background jobs immediately.
- `BG_NICE` don't run all background jobs at a lower priority.
- `HUP` don't kill jobs on shell exit.
- `CHECK_JOBS` don't report on jobs when shell exit.

## Variables

### XDG

- `XDG_CONFIG_HOME` config location
- `XDG_CACHE_HOME` cache location
- `XDG_DATA_HOME` data location
- `XDG_RUNTIME_DIR` runtime location

