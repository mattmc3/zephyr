# confd

This README is validated using the excellent [clitest] testing framework.

## setup

Here we need to handle test setup.

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

## Test missing dir behavior

If the .zshrc.d directory doesn't exist, then fail with a message:

```zsh
% test -d $HOME/.zshrc.d || echo "$HOME/.zshrc.d does not exist" | substenv
$HOME/.zshrc.d does not exist
% source $PWD/plugins/confd/confd.plugin.zsh #=> --exit 1
%
```

## Test empty dir behavior

```zsh
% mkdir -p $HOME/.zshrc.d
% test -d $HOME/.zshrc.d && echo "$HOME/.zshrc.d now exists, but is empty" | substenv
$HOME/.zshrc.d now exists, but is empty
% source $PWD/plugins/confd/confd.plugin.zsh 2>&1 | substenv
% echo ${#sourced_files}
0
%
```

Cleanup:

```zsh
% t_reset
%
```

## Test directory selection

Test selection of dirs from `$HOME`.

Setup:

```zsh
% zstyle ':zephyr:plugin:confd' directory $HOME/.myrc.d
% ZDOTDIR=$HOME/.zsh
% rcdirs=($HOME/.myrc.d $HOME/.zshrc.d)
% rcdirs+=($ZDOTDIR/rc.d $ZDOTDIR/conf.d $ZDOTDIR/zshrc.d $ZDOTDIR/.zshrc.d)
% mkdir -p $rcdirs
% for rcd in $rcdirs; touch $rcd/rcfile.zsh
%
```

If we set the `zstyle` it always overrides everything:

```zsh
% alias source="t_mock_source"  # from now on, use '.' to source for real
% . $PWD/plugins/confd/confd.plugin.zsh | substenv
mock sourcing file... $HOME/.myrc.d/rcfile.zsh
% rm -rf -- $HOME/.myrc.d
% # Now that the zstyle dir is missing, it should fail if the var is still set
% . $PWD/plugins/confd/confd.plugin.zsh #=> --exit 1
% zstyle -e ':zephyr:plugin:confd' directory
%
```

Next, `$ZDOTDIR`, should override `$HOME` in this order:

- `$ZDOTDIR/zshrc.d`
- `$ZDOTDIR/conf.d`
- `$ZDOTDIR/rc.d`
- `$ZDOTDIR/.zshrc.d`

```zsh
% . $PWD/plugins/confd/confd.plugin.zsh | substenv ZDOTDIR
mock sourcing file... $ZDOTDIR/conf.d/rcfile.zsh
% rm -rf -- $HOME/.zsh/conf.d
% . $PWD/plugins/confd/confd.plugin.zsh | substenv ZDOTDIR
mock sourcing file... $ZDOTDIR/zshrc.d/rcfile.zsh
% rm -rf -- $HOME/.zsh/zshrc.d
% . $PWD/plugins/confd/confd.plugin.zsh | substenv ZDOTDIR
mock sourcing file... $ZDOTDIR/rc.d/rcfile.zsh
% rm -rf -- $HOME/.zsh/rc.d
% . $PWD/plugins/confd/confd.plugin.zsh | substenv ZDOTDIR
mock sourcing file... $ZDOTDIR/.zshrc.d/rcfile.zsh
% rm -rf -- $HOME/.zsh/.zshrc.d
% unset ZDOTDIR
%
```

Finally, `$HOME/.zshrc.d` is the default:

```zsh
% . $PWD/plugins/confd/confd.plugin.zsh | substenv HOME
mock sourcing file... $HOME/.zshrc.d/rcfile.zsh
% rm -rf -- $HOME/.zshrc.d
%
```

Cleanup:

```zsh
% t_reset
%
```

## Test normal operation

Setup:

```zsh
% t_setup_rc_files
%
```

Run:

```zsh
% alias source="t_mock_source"  # mock sourcing again
% . $PWD/plugins/confd/confd.plugin.zsh | substenv
mock sourcing file... $HOME/.zshrc.d/a.zsh
mock sourcing file... $HOME/.zshrc.d/b.sh
mock sourcing file... $HOME/.zshrc.d/b.zsh
mock sourcing file... $HOME/.zshrc.d/c.sh
mock sourcing file... $HOME/.zshrc.d/sym.zsh
% unalias source
% source $PWD/plugins/confd/confd.plugin.zsh | substenv
sourced file: $HOME/.zshrc.d/a.zsh
sourced file: $HOME/.zshrc.d/b.sh
sourced file: $HOME/.zshrc.d/b.zsh
sourced file: $HOME/.zshrc.d/c.sh
sourced file: $HOME/foo.zsh
%
```

## Teardown

Here we need to handle test teardown.

```zsh
% t_teardown
%
```

[clitest]: https://github.com/aureliojargas/clitest
