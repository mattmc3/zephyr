# Environment

Init

```zsh
% source ./tests/__init__.zsh
% t_setup
%
```

Test plugin is not initialized

```zsh
% zstyle -t ':zephyr:plugin:environment' loaded || echo "not loaded"
not loaded
% test -v EDITOR  #=> --exit 1
% test -v VISUAL  #=> --exit 1
% set -o | grep -v off | awk '{print $1}' | sort
nohashdirs
norcs
%
```

Initialize plugin

```zsh
% source $ZEPHYR_HOME/plugins/environment/environment.plugin.zsh
%
```

Test plugin is initialized

```zsh
% zstyle -t ':zephyr:plugin:environment' loaded || echo "not loaded"
% test -v EDITOR  #=> --exit 0
% test -v VISUAL  #=> --exit 0
% set -o | grep 'on$' | awk '{print $1}' | sort
autoresume
combiningchars
extendedglob
interactivecomments
longlistjobs
nobeep
nobgnice
nocheckjobs
noflowcontrol
nohashdirs
nohup
norcs
rcquotes
%
```

Teardown

```zsh
% t_teardown
%
```
