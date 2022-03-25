# Completions

Loads and configures <kbd>TAB</kbd> completion.

Also, adds your own custom completions from `${ZDOTDIR:-~/.config/zsh}/completions`.

## Options

- `COMPLETE_IN_WORD` complete from both ends of a word.
- `ALWAYS_TO_END` move cursor to the end of a completed word.
- `AUTO_MENU` show completion menu on a successive <kbd>TAB</kbd> press.
- `AUTO_LIST` automatically list choices on ambiguous completion.
- `AUTO_PARAM_SLASH` if completed parameter is a directory, add a trailing
  slash (`/`).
- `EXTENDED_GLOB` needed for file modification glob modifiers with _compinit_.
- `NO_MENU_COMPLETE` do not autoselect the first completion entry.
- `NO_FLOW_CONTROL` disable start/stop characters in shell editor.

## Variables

- `LS_COLORS` used by default for Zsh [standard style][1] 'list-colors'.

## Settings

### Ignore _`/etc/hosts`_ Entries

To ignore certain entries from static _`/etc/hosts`_ for host completion, add the following lines in _`${ZDOTDIR:-$HOME}/.zshrc`_ with the IP addresses of the hosts as they appear in _`/etc/hosts`_. Both IP address and the associated hostname(s) will be ignored during host completion. However, some of the entries ignored from _`/etc hosts`_ still might appear during completion because of their presence in _ssh_ configuration or history).

```sh
zstyle ':zephyr:plugin:completions:*:hosts' etc-host-ignores \
    '0.0.0.0' '127.0.0.1'
```

[1]: https://zsh.sourceforge.net/Doc/Release/Completion-System.html#Standard-Styles
