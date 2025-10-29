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

Verify that we can correctly match strings.

```sh
$ string match "*" a
a
$ string match "a*b" axxb
axxb
$ string match -i "a**B" Axxb
Axxb
$ echo "ok?" | string match "*?"
ok?
$ string match -r "cat|dog|fish" "nice dog"
dog
$ string match -r "(\d\d?):(\d\d):(\d\d)" 2:34:56
2:34:56
2
34
56
$ string match -r "^(\w{2,4})\g1\$" papa mud murmur
papa
pa
murmur
mur
$ string match -r -a -n at ratatat
2 2
4 2
6 2
$ string match -r -i "0x[0-9a-f]{1,8}" "int magic = 0xBadC0de;"
0xBadC0de
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
