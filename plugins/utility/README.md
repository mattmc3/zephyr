# utility

> Common shell utilities, aimed at making cross-platform work less painful.

## Options

This plugin sets no Zsh options.

## Functions

This plugin adds the following functions:

| function      | description                                                   |
| ------------- | ------------------------------------------------------------- |
| `sedi <args>` | Cross-platform `sed -i` that works on both GNU and BSD `sed`. |

## Aliases

This plugin adds/modifies the following aliases:

| alias      | description                                                            |
| ---------- | ---------------------------------------------------------------------- |
| `help`     | `run-help`: show help for shell builtins and commands                  |
| `ls`       | Adds `-h` flag for human readable file sizes                           |
| `python`   | Alias to `python3` if `python` is not found                            |
| `pip`      | Alias to `pip3` if `pip` is not found                                  |
| `envsubst` | Python fallback if `envsubst` is not found                             |
| `hd`       | `hexdump -C` if `hd` is not found                                      |
| `open`     | Platform alias (`cygstart`, `termux-open`, or `xdg-open`) if not found |
| `pbcopy`   | Platform clipboard copy alias if not found                             |
| `pbpaste`  | Platform clipboard paste alias if not found                            |

## Variables

This plugin sets no variables.

## Customizations

This plugin does not have any zstyles for customization.
