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

```sh
$ # From https://github.com/fish-shell/fish-shell/issues/5201
$ # 'string match -r with empty capture groups'
$ string match -r '^([ugoa]*)([=+-]?)([rwx]*)$' '=r'
=r

=
r
$ ### Test some failure cases
$ (set -o pipefail; string match -r "[" "a[sd" 2>&1 | cut -d';' -f1) && echo "unexpected exit 0"
Unmatched [ in regex
$
```

```sh
$ string match -r -v "[dcantg].*" dog can cat diz || echo "no regexp invert match"
no regexp invert match
$ string match -v "*" dog can cat diz || echo "no glob invert match"
no glob invert match
$ string match -rvn a bbb || echo "exit 1"
1 3
$
```

```sh
$ # Test equivalent matches with/without the --entire, --regex, and --invert flags.
$ string match -e x abc dxf xyz jkx x z || echo exit 1
dxf
xyz
jkx
x
$ string match x abc dxf xyz jkx x z
x
$ string match --entire -r "a*b[xy]+" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz || echo exit 1
abxc
bye
aaabyz
kaabxz
abbxy
caabxyxz
$
$ # 'string match --entire "" -- banana'
$ string match --entire "" -- banana || echo exit 1
banana
$
$ # 'string match -r "a*b[xy]+" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz'
$ string match -r "a*b[xy]+" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz || echo exit 1
abx
by
aaaby
aabx
bxy
aabxyx
$
$ # Make sure that groups are handled correct with/without --entire.
$ # 'string match --entire -r "a*b([xy]+)" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz'
$ string match --entire -r "a*b([xy]+)" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz || echo exit 1
abxc
x
bye
y
aaabyz
y
kaabxz
x
abbxy
xy
caabxyxz
xyx
$
$ # 'string match -r "a*b([xy]+)" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz'
$ string match -r "a*b([xy]+)" abc abxc bye aaabyz kaabxz abbxy abcx caabxyxz || echo exit 1
abx
x
by
y
aaaby
y
aabx
x
bxy
xy
aabxyx
xyx
$
```

More tests

```sh
$ string match -eq asd asd; echo $?
0
$ # --quiet should quit early
$ echo "Checking that --quiet quits early - if this is broken it hangs"
Checking that --quiet quits early - if this is broken it hangs
$ yes | string match -q y; echo $?
0
$
```

```sh
$ string match -rg '(.*)fish' catfish
cat
$ string match -rg '(.*)fish' shellfish
shell
$ # An empty match
$ string match -rg '(.*)fish' fish
$ # No match at all
$ string match -rg '(.*)fish' banana
$ # Make sure it doesn't start matching something
$ string match -r --groups-only '(.+)fish' fish; echo $?
1
$ # Multiple groups
$ string match -r --groups-only '(.+)fish(.*)' catfishcolor
cat
color
$
$ # Examples specifically called out in #6056.
$ echo "foo bar baz" | string match -rg 'foo (bar) baz'
bar
$ echo "foo1x foo2x foo3x" | string match -arg 'foo(\d)x'
1
2
3
$
```

```sh
$ printf "dog\ncat\nbat\ngnat\n" | string match -m2 "*at"
cat
bat
$
$ printf "dog\ncat\nbat\nhog\n" | string match -rvm1 'at$'
dog
$
```

Teardown

```sh
$ # Add teardown steps if needed
$
```
