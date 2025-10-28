# math - perform mathematics calculations

Setup

```sh
$ PATH="$PATH:$PWD/bin"
$ # export BC_CMD=/opt/homebrew/opt/bc/bin/bc
$
```

Test math passes shellcheck

```sh
$ shellcheck --shell sh ./bin/math
$
```

Test math prints its help

```sh
$ math --help | head -n1
math - perform mathematics calculations
$
```

Test that math fails on no args

```sh
$ math #=> --exit 1
$ math
math: expected >= 1 arguments; got 0
$
```

Mimic Fish's own tests from [math.fish](https://github.com/fish-shell/fish-shell/blob/master/tests/checks/math.fish)

```sh
$ # Validate basic expressions
$ math 3 / 2
1.5
$ math 10/6
1.666667
$ math -s0 10 / 6
1
$ math 'floor(10 / 6)'
1
$ math -s3 10/6
1.667
$ math '10 % 6'
4
$ math -s0 '10 % 6'
4
$ math '23 % 7'
2
$ math --scale=6 '5 / 3 * 0.3'
0.5
$ math --scale=max '5 / 3'
1.666666666666667
$ math "7^2"
49
$ math -1 + 1
0
$ math '-2 * -2'
4
$ math 5 \* -2
-10
$ math -- -4 / 2
-2
$ math -- '-4 * 2'
-8
$
$ # Validate max and min
$ math 'max(1,2)'
2
$ math 'min(1,2)'
1
$ # Validate some rounding functions
$ math 'round(3/2)'
2
$ math 'floor(3/2)'
1
$ math 'ceil(3/2)'
2
$ math 'round(-3/2)'
-2
$ math 'floor(-3/2)'
-2
$ math 'ceil(-3/2)'
-1
$ # Validate some integral computations
$ math 1
1
$ math 10
10
$ math 100
100
$ math 1000
1000
$ math '10^15'
1000000000000000
$ math '-10^14'
100000000000000
$ math '-10^15'
-1000000000000000
$ # Floating point operations under x86 without SSE2 have reduced accuracy!
$ # This includes both i586 targets and i686 under Debian, where it's patched to remove SSE2.
$ # As a result, some floating point tests use regular expressions to loosely match against
$ # the shape of the expected result.
$
$ # NB: The i586 case should also pass under other platforms, but not the other way $ around.
$ # math "3^0.5^2"
$ # CHECK: {{1\.316074|1\.316\d+}}
$
$ math -2^2
4
$
$ math -s0 '1.0 / 2.0'
0
$ math -s0 '3.0 / 2.0'
1
$ math -s0 '10^15 / 2.0'
500000000000000
$ # Validate how variables in an expression are handled
$ # math $x + 1
$ # 1
$ x=1
$ math $x + 1
2
$ x=3
$ y=1.5
$ math "-$x * $y"
-4.5
$ math -s0 "-$x * $y"
-4
$
```

Math error handling

```sh
$ # Validate math error reporting
$ # NOTE: The leading whitespace for the carets here is ignored
$ # by littlecheck.
$ math '2 - ' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Too few arguments
$ # CHECKERR: '2 - '
$ # CHECKERR:     ^
$ math 'ncr(1)' 2>&1 #=> --egrep math: error in formula:
1
$ # CHECKERR: math: Error: Too few arguments
$ # CHECKERR: 'ncr(1)'
$ # CHECKERR:       ^
$
$ math "min()" 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Too few arguments
$ # CHECKERR: 'min()'
$ # CHECKERR:      ^
$
$ # There is no "blah" function.
$ math 'blah()' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Unknown function
$ # CHECKERR: 'blah()'
$ # CHECKERR:  ^~~^
$
$ # There is also no "Blah" function.
$ math 'Blah()' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Unknown function
$ # CHECKERR: 'Blah()'
$ # CHECKERR:  ^~~^
$
$ # math q + 4 2>&1
$ # CHECKERR: math: Error: Unknown function
$ # CHECKERR: 'n + 4'
$ # CHECKERR:  ^
$
$
$ math 'sin()' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Too few arguments
$ # CHECKERR: 'sin()'
$ # CHECKERR:      ^
$ math '2 + 2 4' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Missing operator
$ # CHECKERR: '2 + 2 4'
$ # This regex to check whitespace - the error appears between the second 2 and the 4!
$ # (right after the 2)
$ # CHECKERR: {{^}}      ^
$ # printf '<%s>\n' (math '2 + 2      4' 2>&1)
$ # CHECK: <math: Error: Missing operator>
$ # CHECK: <'2 + 2      4'>
$ # CHECK: <      ^~~~~^>
$
$ math '(1 2)' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Missing operator
$ # CHECKERR: '(1 2)'
$ # CHECKERR:    ^
$ math '(1 pi)' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Missing operator
$ # CHECKERR: '(1 pi)'
$ # CHECKERR:    ^
$ math '(1 pow 1,2)' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Missing operator
$ # CHECKERR: '(1 pow 1,2)'
$ # CHECKERR:    ^
$ math 2>&1
math: expected >= 1 arguments; got 0
$ # CHECKERR: math: expected >= 1 arguments; got 0
$ math -s 12
math: expected >= 1 arguments; got 0
$ # CHECKERR: math: expected >= 1 arguments; got 0
$ # XXX FIXME these two should be just "missing argument" errors, the count is not helpful
$ # math 2^999999
$ printf '%s\n' "2^999999" | bc | wc -l | tr -d ' '
4427
$ # CHECKERR: math: Error: Result is infinite
$ # CHECKERR: '2^999999'
$ math 'sqrt(-1)' 2>&1 #=> --egrep math: error in formula:
$ # CHECKERR: math: Error: Result is not a number
$ # CHECKERR: 'sqrt(-1)'
$ # math 'sqrt(-0)'
$ # CHECK: -0
$ # math 2^53 + 1
$ # CHECKERR: math: Error: Result magnitude is too large
$ # CHECKERR: '2^53 + 1'
$ # math -2^53 - 1
$ # CHECKERR: math: Error: Result magnitude is too large
$ # CHECKERR: '-2^53 - 1'
$ # printf '<%s>\n' (not math 1 / 0 2>&1)
$ # CHECK: <math: Error: Division by zero>
$ # CHECK: <'1 / 0'>
$ # CHECK: <   ^>
$ # printf '<%s>\n' (math 1 % 0 - 5 2>&1)
$ # CHECK: <math: Error: Division by zero>
$ # CHECK: <'1 % 0 - 5'>
$ # CHECK: <   ^>
$ # printf '<%s>\n' (math min 1 / 0, 5 2>&1)
$ # CHECK: <math: Error: Division by zero>
$ # CHECK: <'min 1 / 0, 5'>
$ # CHECK: <       ^>
$
```

Math bitwise operator handling

```sh
$ # Add teardown steps if needed
$ math "ibase=16; bitand(FE, 1)"
0
$ math "ibase=16; bitor(FE, 1)"
255
$ math "bitxor(5, 1)"
4
$ math "bitand(5.5, 2)"
0
$ math "bitand(5.5, 1)"
1
$ math "bitor(37 ^ 5, 255)"
69343999
$
```

More math

```sh
$ math 'log10(16)'
1.20412
$ math --base=16 255 / 15
0x11
$ math -bhex 16 * 2
0x20
$ math --base hex 'ibase=16; 0C + 50'
0x5C
$ math --base hex 0
0x0
$ math --base hex -1
-0x1
$ math --base hex -15
-0xF
$ math --base hex 'pow(2,40)'
0x10000000000
$ math --base octal 0
0
$ math --base octal -1
-01
$ math --base octal -15
-017
$ math --base octal 'pow(2,40)'
020000000000000
$ math --base octal --scale=0 55
067
$ math --base notabase 2>&1; err=$?
math: invalid base value 'notabase'.
$ echo $err
2
$
$ math 'log2(8)'
3
$
```

## Teardown

```sh
$
```
