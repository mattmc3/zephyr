# string.plugin.zsh

When it comes to Zsh scripting, a lot of attention is paid to files and the file system, but it's a bit harder to find good documentation around string manipulation. Information about Zsh strings gets buried in docs obscurely labeled [Parameter Expansion][1] or [Modifiers][2]. The [Fish Shell][fish] shell arguably does a much better job with documentation, and has a handy [string][fish-string] command that covers most of the things you'd ever want to do with strings.

This plugin aims to use Fish's `string` subcommands to demonstrate Zsh's string handling capabilities. You don't necessarily need Fish's `string` subcommands in Zsh, but by creating an equivalent Zsh string utility we can quickly show how Zsh accomplishes all the same functionality. And, arguably, provide a nicer interface when interacting with strings in Zsh going forward to aid your shell scripting journey.

## Tests

A brief note on tests:

This README is validated using the excellent [clitest] testing framework. Occasionally in this doc I will need to include some testing snippets. I will try avoid them being too distracting or doing tons of undocumented _magic_. This README itself is meant to contain all the actual code you need, so you should not have to go find buried tricks in other files.

Here are the small handful of _magic_ things done in this doc that you might want to be aware of:
- If you see `#=> --flag` syntax, that's a thing [clitest] uses for certain kinds of tests
- If you see the `#string.plugin.zsh` comment at the top of a code block, I use that to indicate that the code block should be pulled into the `string.plugin.zsh` file
- If you see `##?` comments, we use those to indicate usage strings (aka: help)
- clitests are restricted to one line only, so you'll see bias towards one-liners throughout. (eg: `if/else` multi-line statements become `test && success-part || fail-part`, and `for/do/done` multi-line statements become `for val in $arr; print $val`).
- Due to need to handle any string input including ones with escaped characters and leading hypens, we will favor using `print -r` in the actual string functions instead of `echo`.

Tests are run using the following command:

```zsh
./tests/runtests
```

Here we need to handle test setup.

```zsh
% cd $PWD/plugins/string
% source ./string.plugin.zsh
%
```

With that out of the way, let's begin.

## Fish's `string` command

If you aren't familiar with Fish's [`string`][fish-string] utility, it provides nearly 20 subcommands for dealing with strings. Here is the usage string provided when running `string --help`:

```text
string - manipulate strings

string collect [-a | --allow-empty] [-N | --no-trim-newlines] [STRING ...]
string escape [-n | --no-quoted] [--style=] [STRING ...]
string join [-q | --quiet] [-n | --no-empty] SEP [STRING ...]
string join0 [-q | --quiet] [STRING ...]
string length [-q | --quiet] [STRING ...]
string lower [-q | --quiet] [STRING ...]
string match [-a | --all] [-e | --entire] [-i | --ignore-case]
             [-g | --groups-only] [-r | --regex] [-n | --index]
             [-q | --quiet] [-v | --invert]
             PATTERN [STRING ...]
string pad [-r | --right] [(-c | --char) CHAR] [(-w | --width) INTEGER]
           [STRING ...]
string repeat [(-n | --count) COUNT] [(-m | --max) MAX] [-N | --no-newline]
              [-q | --quiet] [STRING ...]
string replace [-a | --all] [-f | --filter] [-i | --ignore-case]
               [-r | --regex] [-q | --quiet] PATTERN REPLACE [STRING ...]
string shorten [(-c | --char) CHARS] [(-m | --max) INTEGER]
               [-N | --no-newline] [-l | --left] [-q | --quiet] [STRING ...]
string split [(-f | --fields) FIELDS] [(-m | --max) MAX] [-n | --no-empty]
             [-q | --quiet] [-r | --right] SEP [STRING ...]
string split0 [(-f | --fields) FIELDS] [(-m | --max) MAX] [-n | --no-empty]
              [-q | --quiet] [-r | --right] [STRING ...]
string sub [(-s | --start) START] [(-e | --end) END] [(-l | --length) LENGTH]
           [-q | --quiet] [STRING ...]
string trim [-l | --left] [-r | --right] [(-c | --chars) CHARS]
            [-q | --quiet] [STRING ...]
string unescape [--style=] [STRING ...]
string upper [-q | --quiet] [STRING ...]
```

Let's quickly examine Zsh equivalents of each of these string functions:

```zsh
string collect   % arr=(${(@f)$(echo $str)})
string escape    % echo ${str:q}
string join      % echo ${(pj:$sep:)words}
string length    % echo $#str
string lower     % echo ${str:l}
string match     % partial support via zsh/pcre
string pad       % echo ${(l:${len}::string1::string2:)str}
string repeat    % printf "${str}%.0s" {1..$times}
string replace   % echo ${str:gs/pattern/${sub}/}
string shorten   % [[ $#str -lt $len ]] && echo ${str} || echo ${str:0:((len-3))}...
string split     % echo ${(ps:$sep:)str}
string sub       % echo $str[$start,$end]
string trim      % partial support via ${name%pattern} and ${name#pattern}
string unescape  % echo ${str:Q}
string upper     % echo ${str:u}
```

The bulk of the documentation for this syntax is found in the [Parameter Expansion][1] or [Modifiers][2] sections of the Zsh docs.

We could stop right here and have a lot of what we need to know about scripting with strings in Zsh. But looking at that mess of syntax, Zsh gives the strong appearance of being a write-only language like Perl. Remembering this syntax when you need it is painful, and searching the docs can be equally frustrating. Let's spend a little time going farther down the rabbit hole, and wrap this functionality in `string` functions like Fish has.

## String lengths

Let's start with an easy one. In Zsh you get the length of strings using the `$#var` syntax like so:

```zsh
% str="abcdefghijklmnopqrstuvwxyz"
% echo $#str
26
%
```

Fish uses the [string length][string-length] command to handle this. If you wanted the same functionality in Zsh you could write this simple function:

```zsh
#string.plugin.zsh
##? string-length - print string lengths
##? usage: string length [STRING...]
function string-length {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- $#s
  done
}
```

First, we check that arguments were provided or we return a failure status: `(( $# )) || return 1`. Next we loop through the arguments provided, preserving empty strings: `for s in "$@"`. Finally, we print out the length of each string argument: `echo $#s`. Pretty simple, right?

With this function you can now get string lengths similar to how Fish does it:

```zsh
% string-length '' a ab abc
0
1
2
3
%
```

## Changing case

In Zsh you can convert strings to upper or lower case using the `u` or `l` [modifiers][3], **OR** the `U` or `L` [parameter expansion flags][2]. Yep, you read that right - Zsh often has multiple different ways to do the same thing ([TMTOWTDI](https://en.wiktionary.org/wiki/TMTOWTDI)). **AND** it uses funny names for the syntax which makes it difficult to search for. **AND** it changes the case of the letters used depending on which syntax you use! There's a reason Fish markets itself as the Friendly Interactive SHell.

Here's how you use [modifiers][3] to change case:

```zsh
% str="AbCdEfGhIjKlMnOpQrStUvWxYz"
% echo ${str:u}
ABCDEFGHIJKLMNOPQRSTUVWXYZ
% echo ${str:l}
abcdefghijklmnopqrstuvwxyz
%
```

Alternatively, here's how you use [parameter expansion flags][2] to change case:

```zsh
% str="AbCdEfGhIjKlMnOpQrStUvWxYz"
% echo ${(U)str}
ABCDEFGHIJKLMNOPQRSTUVWXYZ
% echo ${(L)str}
abcdefghijklmnopqrstuvwxyz
%
```

Fish handles changing case with the [string lower][string-lower] and [string upper][string-upper] commands. If you like how Fish does things, you can also easily accomplish the same functionality in Zsh with these simple functions:

```zsh
#string.plugin.zsh
##? string-lower - convert strings to lowercase
##? usage: string lower [STRING...]
function string-lower {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:l}
  done
}

##? string-upper - convert strings to uppercase
##? usage: string upper [STRING...]
function string-upper {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:u}
  done
}
```

With these functions you can now get change string case similar to how Fish does it:

```zsh
% string-upper A bb Abc
A
BB
ABC
% string-lower A bb Abc
a
bb
abc
%
```

### Common mistakes

If you forget and use the wrong case for your modifiers your string will be wrong, which is why it's better to enclose your variables in curly braces when using modifiers:

```zsh
% # EPIC FAIL EXAMPLES:
% # modifiers without curly braces may succeed in unexpected ways
% echo $str:U
AbCdEfGhIjKlMnOpQrStUvWxYz:U
% # use curly braces when using modifiers:
% echo ${str:U}  #=> --regex unrecognized modifier
% # zsh: unrecognized modifier `U'
%
```

If you accidentally used the wrong case when you use parameter expansion flags you're in for a surprise because the lowercase `u` is used to apply uniqueness to the result.

```zsh
% # EPIC FAIL EXAMPLES:
% # parameter expansion flags - use (U) not (u), and (L) not (l)
% arr=(aAa bBb cCc AaA cCc)
% echo ${(U)arr}
AAA BBB CCC AAA CCC
% # don't make a mistake here or it will fail successfully
% echo ${(u)arr}
aAa bBb cCc AaA
%
```

## Trimming strings

Trimming strings (also known as stripping) means removing leading or trailing content from a string. Zsh only has partial support for trimming strings as we'll see.

If you want to remove the leading or trailing part of a string, _and you can accurately represent that leading part with a simple glob pattern_, you can accomplish that with the `#` and `%` [parameter expansions][4].

The `#` expansion removes from the start of the string. A single `#` removes the shortest match, while a `##` removes the longest.

```zsh
% str="a/b/c/d/e/f/g"
% # remove 'a/'
% echo ${str#*/}
b/c/d/e/f/g
% # remove 'a/b/c/d/e/f/'
% echo ${str##*/}
g
%
```

The `%` expansion removes from the end of the string. A single `%` removes the shortest match, while a `%%` removes the longest.

```zsh
% str="a/b/c/d/e/f/g"
% # remove '/g'
% echo ${str%/*}
a/b/c/d/e/f
% # remove '/b/c/d/e/f/g'
% echo ${str%%/*}
a
%
```

More commonly, we want to remove leading and trailing whitespace from a string. Once we start to get into patterns like "spaces or newlines or tabs or carriage returns or ..." we run into trouble sticking to Zsh builtins. This is what tools like `sed` are built for. If you like Fish's [string trim][string-trim] command, and just care about trimming whitespace, we can make a trim function that wraps `sed` like this:

```zsh
#string.plugin.zsh
##? string-trim - remove leading and trailing whitespace
##? usage: string trim [STRING...]
function string-trim {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  printf '%s\n' "$@" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}
```

`sed` can feel a lot like _magic_, especially if you don't understand [regular expression][regex] patterns, however there is no better Zsh built-in alternative here. To make it even more complicated, there are Perl Compatible Regular Expressions (PCREs) and Basic Regular Expressions (BREs). Teaching regex is outside the scope of this document. The important part to note here is that we use `^` and `$` to anchor our trim to the beginning and end of the string respectively. See the POSIX specifications to learn more about [`sed`][sed] and [Basic Regular Expressions][basic-re].

Let's try out our new `string-trim` function:

```zsh
% string-trim "  a b c  "
a b c
% # set tab and newline variables
% tab=$'\t'
% nl=$'\n'
% string-trim "${tab}x y z${tab}"
x y z
% # surround results with pipes to better see that right trim is working
% echo "|$(string-trim "  ${tab}${tab}  ${tab} a b c${tab}  ${nl}${nl} ")|"
|a b c|
%
```

## Escaping strings

Strings often have characters in them that need 'escaped' or 'quoted' properly. Quoting strings is done with the [q modifier][1], and unquoting is done with the [Q modifier][1]. This is similar to [string escape][string-escape] and [string unescape][string-unescape] in Fish.

```zsh
% str="3 tabs \t\t\t."
% echo ${str:q}
3\ tabs\ \t\t\t.
% str='3 backslashes \\\\\\.'
% echo $str
3 backslashes \\\.
% echo ${str:q}
3\ backslashes\ \\\\\\.
% echo ${${str:q}:Q}
3 backslashes \\\.
%
```

In Zsh you can quote strings many different ways using `q`, `qq`, `qqq`, `qqqq`, as well as `q-` and `q+`. Each outputs different kinds of quoting:

- `q`: Quote characters that are special to the shell with backslashes
- `qq`: Quote with results in 'single' quotes
- `qqq`: Quote with results in "double" quotes
- `qqq`: Quote with results in $'dollar' quotes
- `q-`: Minimal quoting only where required
- `q+`: Extended minimal quoting using $'dollar'

```zsh
% tab=$'\t'
% str="\\\\backslash, tab (\t), and \`backticks\`."
% echo $str
\backslash, tab (	), and `backticks`.
% echo ${(q)str}
\\backslash,\ tab\ \(\t\),\ and\ \`backticks\`.
% echo ${(qq)str}
'\backslash, tab (	), and `backticks`.'
% echo ${(qqq)str}
"\\backslash, tab (\t), and \`backticks\`."
% echo ${(qqqq)str}
$'\\backslash, tab (\t), and `backticks`.'
% echo ${(q-)str}
'\backslash, tab (	), and `backticks`.'
% echo ${(q+)str}
'\backslash, tab (	), and `backticks`.'
%
```

Or, you can use write your own `string escape` and `string unescape` convenience functions to do the same thing. Use whichever method of quoting you prefer.

```zsh
#string.plugin.zsh
##? string-escape - escape special characters
##? usage: string escape [STRING...]
function string-escape {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:q}
  done
}

##? string-unescape - expand escape sequences
##? usage: string unescape [STRING...]
function string-unescape {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  for s in "$@"; do
    print -r -- ${s:Q}
  done
}
```

Now we can use functions similar to Fish's for string escaping.

```zsh
% excited_man='\\o/'
% echo $excited_man
\o/
% print -r -- $excited_man
\\o/
% string-escape $excited_man
\\\\o/
%
```

And for unescaping.

```zsh
% esc_man='\\\\o/'
% echo $esc_man
\\o/
% print -r -- $esc_man
\\\\o/
% string-unescape $esc_man
\\o/
%
```

## Joining strings

Fish handles joining strings with the [string join][string-join] command. In Zsh we can join strings with a separator using the `j` [parameter expansion flag][2].

```zsh
% words=(abc def ghi)
% sep=:
% echo ${(pj.$sep.)words}
abc:def:ghi
%
```

A common join separator is the null character (`$'\0'`). Many shell utilities will generate null separated data. For example, `find` does this with the `-print0` option.

```zsh
% find . -maxdepth 1 -type f -name '*.*' -print0 | tr '\0' '0' && echo
./README.md0./string.plugin.zsh0
%
```

_Note: Since the null character isn't viewable, we'll replace it with `0` in these examples using `| tr '\0' '0'` so it's visible for demo purposes._

Fish also includes the [`join0`][string-join0] command, which is just a special case of `join` with the null character as a separator, but with one notable exception; the result tacks on a trailing null character. Notice how the `find -print0` example above also does this. In Zsh, we can accomplish this simply by adding an empty element to the end of whatever list we're joining.

```zsh
% words=(abc def ghi '')
% nul=$'\0'
% echo ${(pj.$nul.)words} | tr '\0' '0'
abc0def0ghi0
%
```

If you prefer how Fish handles string joining, you can easily accomplish the same thing in Zsh with these two simple join functions:

```zsh
#string.plugin.zsh
##? string-join - join strings with delimiter
##? usage: string join SEP [STRING...]
function string-join {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local sep=$1; shift
  print -r -- ${(pj.$sep.)@}
}

##? string-join0 - join strings with null character
##? usage: string join0 [STRING...]
function string-join0 {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  string-join $'\0' "$@" ''
}
```

Now we can use `join` commands in Zsh too.

```zsh
% string-join '/' a b c
a/b/c
% string-join0 x y z | tr '\0' '0'
x0y0z0
%
```

## Splitting strings

Similar to joining strings, Zsh can also split them up. To split strings you use the `s` [parameter expansion flag][2].

```zsh
% str="a/b//c"
% sep=/
% echo ${(ps.$sep.)str}
a b c
% printf '%s\n' "${(@ps.$sep.)str}"
a
b

c
%
```

Let's break down all the [expansion flags][2] we're using here:

- `@`: Preserve empty elements - _"In double quotes, array elements are put into separate words"_.
- `p`: Use print syntax - _"Recognize the same escape sequences as the print."_
- `s`: Split - _"Force field splitting at the separator string."_

Similar to `join`, `split` is also commonly needs to operate on the null character (`$'\0'`) as a delimiter. Let's show how that works with our `find -print0` command:

```zsh
% nul=$'\0'
% files=$(find . -maxdepth 1 -type f -name '*.*' -print0)
% echo $files | tr '\0' '0'
./README.md0./string.plugin.zsh0
% printf '%s\n' "${(@ps.$nul.)files}"
./README.md
./string.plugin.zsh

%
```

Oops. Did you notice what happened there? That trailing null character bit us when we split and we wound up with a trailing empty element. We can fix that in a couple of ways.

First, we could just throw away empty strings:

```zsh
% printf '%s\n' ${(ps.$nul.)files}
./README.md
./string.plugin.zsh
%
```

That works when we don't care about empty strings, but when we don't want to lose data we could also remove the trailing null character:

```zsh
% # setup
% nul=$'\0'
% str=$(echo a00b0 | tr '0' '\0')
% # remove the trailing null
% str=${str%$nul}
% # now, show us the correct results
% printf '%s\n' "${(@ps.$nul.)str}"
a

b
%
```

Now, let's make simple `split` functions similar to Fish's [string split][string-split] and [string split0][string-split0] so that we can more easily split strings.

```zsh
#string.plugin.zsh
##? string-split - split strings by delimiter
##? usage: string split SEP [STRING...]
function string-split {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  printf '%s\n' "${(@ps.$1.)@[2,-1]}"
}

##? string-split0 - split strings by null character
##? usage: string split0 [STRING...]
function string-split0 {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  set -- "${@%$'\0'}"
  string-split $'\0' "$@"
}
```

> Wait a second! You said no _magic_! What the heck is `${(@ps.$1.)@[2,-1]}` and `set -- "${@%$'\0'}"`!?

Those statements are really tricky. Let's break them down.

- `${(@ps.$1.)@[2,-1]}` : This simply says - perform a split to an array, and use the first argument (`$1`) as the separator and the rest of the arguments (`$@[2,-1]`) as the strings to split.

`set -- "${@%$'\0'}"` : This says - re-set the argument array `$@` to whatever was already in the argument array, but remove the final trailing null character from each element if it exists. We learned about the `${name%pattern}` right strip parameter expansion in the [trim](#trimming-strings)) section of this doc.

Now that I've explained all that, we can see how our new `split` commands work in Zsh.

```zsh
% string-split '/' "a/b" "x/y/z"
a
b
x
y
z
% str=$(printf 'a0b0c0' | tr '0' '\0')
% string-split0 "$str"
a
b
c
%
```

## Substrings

Again, like many areas of Zsh, there are multiple different ways to get a substring in Zsh. Zsh also refers to substrings as 'parameter subscripting', which makes it difficult to find in the docs.

In Zsh you get substrings using the `$name[start,end]` syntax, or the `${name:offset:length}` syntax. With `$name[start,end]` syntax, `start` and `end` refer to the 1-based index position. You can also use negative numbers to index from the end of a string.

```zsh
% name="abcdefghijklmnopqrstuvwxyz"
% echo $name[3,6]
cdef
% echo $name[-3,-1]
xyz
%
```

With the `${name:offset:length}` syntax, `offset` is a 0-based index. Negative indexing is also supported, but requires you to surround the number with parenthesis so that the negative number isn't mistaken for the `${name:-word}` substitution syntax. The length portion is optional, and if omitted means 'go to the end of the string'.

```zsh
% name="abcdefghijklmnopqrstuvwxyz"
% echo ${name:2:4}
cdef
% echo ${name:24:100}
yz
% echo ${name:(-4)}
wxyz
% echo ${name:(-15):(-3)}
lmnopqrstuvw
%
```

Fish handles substrings with the [string sub][string-sub] command. You can easily accomplish something similar in Zsh with your own version of this function:

```zsh
#string.plugin.zsh
##? string-sub - extract substrings
##? usage: string sub [-s start] [-e end] [STRINGS...]
function string-sub {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local -A opts=(-s 1 -e '-1')
  zparseopts -D -F -K -A opts -- s: e: || return 1
  local s
  for s in "$@"; do
    print -r -- $s[$opts[-s],$opts[-e]]
  done
}
```

This function is a little more involved than previous examples because we need to pass option arguments. We use `zparseopts`, and if you are unfamiliar with that Zsh builtin take a second and [familiarize yourself with it here](#zparseopts).

`string-sub` uses the `-s` option for the starting position. If not provided, it gets a default value of 1, which is the first position in the string. The `-e` option is the desired final position of the substring. If not supplied, it gets a default value of -1, which means the end of the string.

With this function you can now work with substrings similar to how Fish does:

```zsh
% string sub -s 2 -e 3 abcde
bc
% string sub -s-2 abcde
de
% string sub -e3 abcde
abc
% string sub -e-5 abcde
a
% string sub -s2 -e-3 abcde
bc
% string sub -s -5 -e -3 abcdefgh
def
% string sub -s -100 -e -3 abcde
abc
% string sub -s -5 -e 2 abcde
ab
% string sub -s -50 -e -100 abcde

% string sub -s 2 -e -5 abcde

%
```

If you prefer 0-based indexing, you can do that too:

```zsh
#string.plugin.zsh
##? string-sub0 - extract substrings using 0-based indexing
##? usage: string sub0 [-o offset] [-l len] [STRINGS...]
function string-sub0 {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local -A opts=(-o 0)
  zparseopts -D -K -A opts -- o: l:
  local s
  for s in "$@"; do
    print -r -- ${s:$opts[-o]:${opts[-l]:-$#s}}
  done
}
```

With the `string-sub0` function you can now get substrings using 0-based offset/length indexing:

```zsh
% string-sub0 -o1 -l 2 abcde
bc
% string-sub0 -o-2 abcde
de
% string-sub0 -l3 abcde
abc
% string-sub0 -o-6 -l1 abcde
a
% string-sub0 -o -6 -l 2 abcde
ab
%
```

## String padding

In Zsh you can left pad strings using the `l:expr::string1::string2:` syntax. Similarly, right padding is done by changing the leading `l` to an `r` like this `r:expr::string1::string2:`. This is described in the [Expansion Flags][2] section of the Zsh docs.

This can be confusing, so let's look at a some examples.

```zsh
% str="abc"
% echo ${(l:7:: :)str}
    abc
% echo ${(l:10::-:)str}
-------abc
% echo ${(r:6::.:)str}
abc...
% echo ${(l:10::-#::=:)str}
-#-#-#=abc
%
```

Fish handles this with the [string pad][string-pad] command. You can easily accomplish the same thing in Zsh with your own version of this function:

```zsh
#string.plugin.zsh
##? string-pad - pad strings to a fixed width
##? usage: string pad [-r] [-c padchar] [-w width] [STRINGS...]
function string-pad {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s rl padexp
  local -A opts=(-c ' ' -w 0)
  zparseopts -D -K -F -A opts -- r c: w: || return 1
  for s in "$@"; do
    [[ $#s -gt $opts[-w] ]] && opts[-w]=$#s
  done
  for s in "$@"; do
    [[ -v opts[-r] ]] && rl='r' || rl='l'
    padexp="$rl:$opts[-w]::$opts[-c]:"
    eval "print -r -- \"\${($padexp)s}\""
  done
}
```

This function is a lot more complicated than previous examples, so let's break it down. First, we need to parse options again. The `-c padchar` option is for the padding character, defaulting to a single space. The `-w width` option tells us how far out to pad. If `-w` isn't specified, we use the length of the longest string provided to the function. The `-r` option switches from the default left padding to the right side.

We also use the `[[ test ]]` syntax. `[[ -v var ]]` tests whether a variable is set. `[[ num1 -gt num2 ]]` tests whether num1 is greater than num2.

And finally, we build out a padding expression but have to `eval` it because Zsh doesn't allow the padding expression to use variables like we need it to.

With this function you can now pad strings similar to how Fish does:

```zsh
% string pad -c. long longer longest
...long
.longer
longest
% string pad -c ' ' -w8 a ccc bb dddd
       a
     ccc
      bb
    dddd
% string pad -c_ -w5 -r a ccc bb dddd
a____
ccc__
bb___
dddd_
%
```

## Shortening

Fish also provides a way to [shorten strings][string-short] and add an ellipsis to the end. For example:

```zsh
% str="abcdefghijklmnopqrstuvwxyz"
% len=6
% [[ $#str -lt $len ]] && echo ${str} || echo ${str:0:((len-1))}…
abcde…
% [[ $#str -lt $len ]] && echo ${str} || echo ${str:0:((len-3))}...
abc...
%
```

Note: the `test && succeed || fail` patten is really common in shell scripting. It basically reads as "if a test succeeds, do a thing, otherwise do something else". It's a shorthand way of writing an `if/else` statement. Our previous command could also have been written like so:

```zsh
if [[ $#str -lt $len ]]
then
  echo ${str}
else
  echo ${str:0:((len-3))}...
fi
```

Given everything we now know about strings in Zsh, this one should feel relatively straightforward:

```zsh
#string.plugin.zsh
##? string-shorten - shorten strings to a max width, with an ellipsis
##? usage: string shorten [-c] [-m max] [STRINGS...]
function string-shorten {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local -A opts=(-c …)
  zparseopts -D -K -A opts -- c: m:
  # user provided max len, or take the shortest string length
  local s len=$#1
  if [[ -v opts[-m] ]]; then
    len=$opts[-m]
  else
    for s in "$@"; [[ $#s -lt $len ]] && len=$#s
  fi
  for s in "$@"; do
    if [[ $#s -gt $len ]]; then
      print -r -- ${s:0:((len-$#opts[-c]))}${opts[-c]}
    else
      print -r -- $s
    fi
  done
}
```

```zsh
% str="abcdefghijklmnopqrstuvwxyz"
% string-shorten -m 6 $str
abcde…
% string-shorten -c '...' -m 6 $str 'xyzxyzxyz' 'short'
abc...
xyz...
short
% string-shorten long longer longest reallyreallylong
long
lon…
lon…
rea…
%
```

## Repeating strings

Strings can be repeated by using `printf`, which outputs based on a format string.

```zsh
$ str="abc"
$ printf "$str%.0s" {1..3}
abcabcabc
$
```

Let's start off creating a simple `string repeat` function to wrap this.

```zsh
# string repeat - simple version
function string-repeat {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s
  local -A opts=(-n 1)
  zparseopts -D -K -A opts -- n:
  for s in "$@"; do
    printf "$s%.0s" {1..$opts[-n]}
    printf "\n"
  done
}
```

And we can test it:

```zsh
% string-repeat -n 3 abc xyz
abcabcabc
xyzxyzxyz
%
```

This function will work, but Fish's [string repeat][string-repeat] has a few more bells and whistles. If you want to support `-m` for a max string length and `-N` to suppress newlines just like Fish's `string repeat` command does, you could implement it this way:

```zsh
#string.plugin.zsh
##? string-repeat - multiply a string
##? usage: string repeat [-n count] [-m max] [-N][STRING ...]
function string-repeat {
  emulate -L zsh; setopt local_options
  (( $# )) || return 1
  local s n
  local -A opts
  zparseopts -D -A opts -- n: m: N
  n=${opts[-n]:-$opts[-m]}
  for s in "$@"; do
    s=$(printf "$s%.0s" {1..$n})
    [[ -v opts[-m] ]] && printf "${s:0:$opts[-m]}" || printf "$s"
    [[ -v opts[-N] ]] || printf '\n'
  done
}
```

Now our string-repeat function behaves more like Fish's [string-repeat].

```zsh
### Test repeat subcommand
% string-repeat -n 2 foo
foofoo
% string-repeat -n1 -N "there is "; echo "no newline"
there is no newline
% string-repeat -n10 -m4 foo
foof
% string-repeat -n10 -m5 foo
foofo
% string-repeat -n3 -m20 foo
foofoofoo
% string-repeat -m4 foo
foof
% string-repeat -n 5 a b c
aaaaa
bbbbb
ccccc
% string-repeat -n 5 -m4 123 456 789
1231
4564
7897
% string-repeat -n 5 -m4 123 '' 789
1231

7897
%
```

## String replace

TODO:

## String match

TODO:

## The `string` wrapper

Fish's [`string` command][fish-string] wraps all this functionality and handles pipe input too. You can also easily accomplish the same thing in Zsh.

```zsh
#string.plugin.zsh
##? string - manipulate strings
function string {
  emulate -L zsh; setopt local_options
  0=${(%):-%x}

  if [[ "$1" == (-h|--help) ]]; then
    grep "^##? string -" ${0:A} | cut -c 5-
    echo "usage:"
    grep "^##? usage:" ${0:A} | cut -c 11- | sort
    return
  fi

  if [[ ! -t 0 ]] && [[ -p /dev/stdin ]]; then
    if (( $# )); then
      set -- "$@" "${(@f)$(cat)}"
    else
      set -- "${(@f)$(cat)}"
    fi
  fi

  if (( $+functions[string-$1] )); then
    string-$1 "$@[2,-1]"
  else
    echo >&2 "string: Subcommand '$1' is not valid." && return 1
  fi
}
```

Now, all your string commands can accept piped input too:

```zsh
% printf '%s\n' a bb ccc | string length
1
2
3
% printf '%s\n' a bb ccc | string pad -c.
..a
.bb
ccc
%
```

## Additional testing

Here, we do any final testing of our string utilities.

Show that unrecognized subcommands fail properly:

```zsh
% string foo #=> --exit 1
% string foo
string: Subcommand 'foo' is not valid.
%
```

## Additional notes

### Fish's `--quiet` flag

Many of Fish's `string` commands include a `-q | --quiet` flag to suppress output. None of our examples here do that because in a POSIX shell, like Zsh, the preferred method for suppressing stdin is simply redirecting it to `/dev/null` like so:

```zsh
% echo "Secret message" >/dev/null
%
```

Fish also lets you add `>/dev/null` to commands, but it includes the `--quiet` flag too. For the purposed of this demo, it's unnecessary to support a `-q` flag in nearly every command when there's a preferred alternative.

### Fish's `string collect`

We didn't show an example of writing a [`string-collect`](string-collect) function because that may be needed for Fish, but makes less sense in Zsh.

However, for completeness, it's worth noting how to collect multi-line input into a string, or into an array by combining the `@` and `f` expansion flags in Zsh like so:

```zsh
% str=$(echo "one\ntwo\nthree")
% echo $str
one
two
three
% arr=( ${(@f)str} )
% echo $#arr
3
% printf '[%s]\n' $arr
[one]
[two]
[three]
%
```

### zparseopts

Many of these scripts use the `zparseopts` builtin to parse arguments. You will see this pattern throughout this doc:

```zsh
local -A opts=(-x 1 -z 3)
zparseopts -D -F -K -A opts -- x: y z: || return 1
```

If you are not familiar with `zparseopts`, you can [read more in the docs][zparseopts]. The short explanation is that we are telling `zparseopts` to:

- **delete (`-D`)** parsed options from `$@`.
- **fail (`-F`)** if a bad option is passed by the user.
- **keep (`-K`)** any options we've already set in the `$opts` associative array. "Associative array" is another word for a key/value dictionary.
- use the **associative array named 'opts' (`-A opts`)** to store the parsed options.

### Supported Zsh Version

A quick note on Zsh versions - the scripts in this doc are verified with a modern release of Zsh only. There may be subtle differences in these scripts on previous Zsh versions. Backward compatibility is not a primary concern here, but if it is a problem for you, you might need to be careful with `zparseopts` usage since its behavior has changed over the years. You can read more about Zsh releases on the [news page][zsh-news].


[1]: https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion
[2]: https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
[3]: https://zsh.sourceforge.io/Doc/Release/Expansion.html#Modifiers
[4]: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fpcre-Module
[fish]: https://fishshell.com
[fish-string]: https://fishshell.com/docs/current/cmds/string.html
[string-collect]: https://fishshell.com/docs/current/cmds/string-collect.html
[string-escape]: https://fishshell.com/docs/current/cmds/string-escape.html
[string-join]: https://fishshell.com/docs/current/cmds/string-join.html
[string-join0]: https://fishshell.com/docs/current/cmds/string-join0.html
[string-length]: https://fishshell.com/docs/current/cmds/string-length.html
[string-lower]: https://fishshell.com/docs/current/cmds/string-lower.html
[string-match]: https://fishshell.com/docs/current/cmds/string-match.html
[string-pad]: https://fishshell.com/docs/current/cmds/string-pad.html
[string-repeat]: https://fishshell.com/docs/current/cmds/string-repeat.html
[string-replace]: https://fishshell.com/docs/current/cmds/string-replace.html
[string-split]: https://fishshell.com/docs/current/cmds/string-split.html
[string-split0]: https://fishshell.com/docs/current/cmds/string-split0.html
[string-sub]: https://fishshell.com/docs/current/cmds/string-sub.html
[string-trim]: https://fishshell.com/docs/current/cmds/string-trim.html
[string-unescape]: https://fishshell.com/docs/current/cmds/string-unescape.html
[string-upper]: https://fishshell.com/docs/current/cmds/string-upper.html
[clitest]: https://github.com/aureliojargas/clitest
[zsh-news]: https://zsh.sourceforge.io/News/
[zparseopts]: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#index-zparseopts
[sed]: https://pubs.opengroup.org/onlinepubs/009695399/utilities/sed.html
[basic-re]: https://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap09.html#tag_09_03
[regex]: https://www.regular-expressions.info/
