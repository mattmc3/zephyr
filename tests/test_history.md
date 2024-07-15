# history

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:history' loaded || echo "not loaded"
not loaded
% test "$SAVEHIST" -le 1000  #=> --exit 0
% test "$HISTSIZE" -le 2000  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/history/history.plugin.zsh; setopt clobber
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:history' loaded || echo "not loaded"
% echo "$SAVEHIST"
100000
% echo "$HISTSIZE"
20000
% set -o | grep 'on$' | sort
extendedglob          on
extendedhistory       on
histexpiredupsfirst   on
histfindnodups        on
histignorealldups     on
histignoredups        on
histignorespace       on
histreduceblanks      on
histsavenodups        on
histverify            on
incappendhistory      on
interactivecomments   on
nohashdirs            on
nohistbeep            on
norcs                 on
%
```

Teardown

```zsh
% t_teardown
%
```
