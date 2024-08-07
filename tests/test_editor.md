# editor

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:editor' loaded || echo "not loaded"
not loaded
% test $+functions[bindkey-all] = 0  #=> --exit 0
% test -v key_info #=> --exit 1
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/editor/editor.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:editor' loaded || echo "not loaded"
% test $+functions[bindkey-all] = 1  #=> --exit 0
% test -v key_info #=> --exit 0
% set -o | grep 'on$' | sort
extendedglob          on
interactivecomments   on
nobeep                on
noflowcontrol         on
nohashdirs            on
norcs                 on
%
```

Teardown

```zsh
% t_teardown
%
```
