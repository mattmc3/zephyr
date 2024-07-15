# completion

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:completion' loaded || echo "not loaded"
not loaded
% test $+functions[compinit] = 0  #=> --exit 0
% test $+functions[compstyle_zephyr_setup] = 0  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/completion/completion.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:completion' loaded || echo "not loaded"
% test $+functions[compinit] = 1  #=> --exit 0
% test $+functions[compstyle_zephyr_setup] = 1  #=> --exit 0
% set -o | grep 'on$' | sort
alwaystoend           on
completeinword        on
extendedglob          on
interactivecomments   on
nocaseglob            on
noflowcontrol         on
nohashdirs            on
norcs                 on
pathdirs              on
%
```

Teardown

```zsh
% t_teardown
%
```
