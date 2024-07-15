# directory

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:directory' loaded || echo "not loaded"
not loaded
% test $+functions[up] = 0  #=> --exit 0
% test $+aliases[dirh] = 0  #=> --exit 0
% set -o | grep -v off | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/directory/directory.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:directory' loaded || echo "not loaded"
% test $+functions[up] = 1  #=> --exit 0
% test $+aliases[dirh] = 1  #=> --exit 0
% t_print_changedopts
autopushd             on
extendedglob          on
noglobalrcs           off
globdots              on
pushdminus            on
pushdsilent           on
pushdtohome           on
%
```

Teardown

```zsh
% t_teardown
%
```
