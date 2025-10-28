# string-match - match strings

Setup

```sh
$ PATH="$PATH:$PWD/bin"
$
```

Test string-match passes shellcheck

```sh
$ shellcheck --shell bash ./bin/string-match
$
```

Test that string match works

```sh
$ string-match -r '[aeiou]' 'abby road'
a
$ string-match -re '[aeiou]' 'abby road'
abby road
$ string-match -ra '[aeiou]' 'abby road'
a
o
a
$
```

Mimic Fish's own tests from [string.fish](https://github.com/fish-shell/fish-shell/blob/master/tests/checks/string.fish)

```sh
$ string match -r -v "c.*" dog can cat diz && echo "exit 0"
dog
diz
exit 0
$ string match -q -r -v "c.*" dog can cat diz && echo "exit 0"
exit 0
$ string match -v "c*" dog can cat diz && echo "exit 0"
dog
diz
exit 0
$ string match -q -v "c*" dog can cat diz && echo "exit 0"
exit 0
$ string match -v "d*" dog dan dat diz || echo "exit 1"
exit 1
$ string match -q -v "d*" dog dan dat diz || echo "exit 1"
exit 1
$ string match -r -v x y && echo "exit 0"
y
exit 0
$ string match -r -v x x || echo "exit 1"
exit 1
$ string match -q -r -v x y && echo "exit 0"
exit 0
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
