# compstyle

> A completion style system modeled after Zsh's prompt system.

## Options

This plugin sets no Zsh options.

## Functions

This plugin adds the following functions:

| function                 | description                                                    |
| ------------------------ | -------------------------------------------------------------- |
| `compstyleinit`          | Load and initialize the completion style system.               |
| `compstyle <style>`      | Switch to the named completion style.                          |
| `compstyle -l`           | List available completion styles.                              |
| `compstyle -h [<style>]` | Show help for the completion style system or a specific style. |
| `compstyle_zephyr_setup` | Apply the built-in `zephyr` completion style.                  |

## Aliases

This plugin sets no aliases.

## Variables

This plugin sets no variables.

## Customizations

To use case-sensitive completion matching:

`zstyle ':zephyr:plugin:compstyle:*' 'case-sensitive' 'yes'`
