# set_color

Init

```zsh
% source ./tests/__init__.zsh
% fpath+=($ZEPHYR_HOME/plugins/color/functions)
% autoload -Uz set_color
%
```

Simple red

```zsh
% colors=($(set_color red)); printf '%s\n' ${(q)colors}
$'\033'\[31m
%
```

Basic 8-colors

```zsh
% set_color black | string-escape
\e\[30m
% set_color red | string-escape
\e\[31m
% set_color green | string-escape
\e\[32m
% set_color yellow | string-escape
\e\[33m
% set_color blue | string-escape
\e\[34m
% set_color magenta | string-escape
\e\[35m
% set_color cyan | string-escape
\e\[36m
% set_color white | string-escape
\e\[37m
%
```

Bright 8-colors

```zsh
% set_color brblack | string-escape
\e\[90m
% set_color brred | string-escape
\e\[91m
% set_color brgreen | string-escape
\e\[92m
% set_color bryellow | string-escape
\e\[93m
% set_color brblue | string-escape
\e\[94m
% set_color brmagenta | string-escape
\e\[95m
% set_color brcyan | string-escape
\e\[96m
% set_color brwhite | string-escape
\e\[97m
%
```

Alias 8-colors

```zsh
% set_color brown | string-escape
\e\[33m
% set_color brbrown | string-escape
\e\[93m
% set_color purple | string-escape
\e\[35m
% set_color brpurple | string-escape
\e\[95m
% set_color grey | string-escape
\e\[37m
% set_color brgrey | string-escape
\e\[90m
%
```

Print bold blue

```zsh
% echo $(set_color --bold blue)blue$(set_color normal) | string-escape
\e\[1m\e\[34mblue\e\(B\e\[m
%
```

Print italic, dim, bold, underline, reverse with background

```zsh
% echo $(set_color -roudi -b yellow cyan)bg:yellow fg:cyan$(set_color normal) | string-escape
\e\[1m\e\[4m\e\[3m\e\[2m\e\[7m\e\[36m\e\[43mbg:yellow\ fg:cyan\e\(B\e\[m
% # order of args should not matter
% echo $(set_color --reverse --italics --dim --underline --bold --background purple brmagenta)bg:purple fg:brmagenta$(set_color normal) | string-escape
\e\[1m\e\[4m\e\[3m\e\[2m\e\[7m\e\[95m\e\[45mbg:purple\ fg:brmagenta\e\(B\e\[m
%
```

Print

```zsh
% echo $(set_color -roudi -b yellow cyan)bg:yellow fg:cyan$(set_color normal) | string-escape
\e\[1m\e\[4m\e\[3m\e\[2m\e\[7m\e\[36m\e\[43mbg:yellow\ fg:cyan\e\(B\e\[m
%
```

```zsh
% set_color --print-colors | string-escape
\e\[31mblack\e\(B\e\[m
\e\[32mred\e\(B\e\[m
\e\[33mgreen\e\(B\e\[m
\e\[34myellow\e\(B\e\[m
\e\[35mblue\e\(B\e\[m
\e\[36mmagenta\e\(B\e\[m
\e\[37mcyan\e\(B\e\[m
\e\[90mwhite\e\(B\e\[m
\e\[91mbrblack\e\(B\e\[m
\e\[92mbrred\e\(B\e\[m
\e\[93mbrgreen\e\(B\e\[m
\e\[94mbryellow\e\(B\e\[m
\e\[95mbrblue\e\(B\e\[m
\e\[96mbrmagenta\e\(B\e\[m
\e\[97mbrcyan\e\(B\e\[m
\e\[38;5;16mbrwhite\e\(B\e\[m
normal
%
```
