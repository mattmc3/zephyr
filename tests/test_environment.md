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
%
```

Teardown

```zsh
% t_teardown
%
```
