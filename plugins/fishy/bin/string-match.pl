#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);

# Simple options class
package MatchOptions {
    sub new {
        my ($class, %args) = @_;
        return bless \%args, $class;
    }

    sub all         { $_[0]->{all} }
    sub entire      { $_[0]->{entire} }
    sub groups_only { $_[0]->{groups_only} }
    sub help        { $_[0]->{help} }
    sub ignore_case { $_[0]->{ignore_case} }
    sub index       { $_[0]->{index} }
    sub invert      { $_[0]->{invert} }
    sub max_matches { $_[0]->{max_matches} }
    sub quiet       { $_[0]->{quiet} }
    sub regex       { $_[0]->{regex} }
}

package main;

sub usage {
    print "string match [-a | --all] [-e | --entire] [-i | --ignore-case]\n";
    print "             [-g | --groups-only] [-r | --regex] [-n | --index]\n";
    print "             [-q | --quiet] [-v | --invert] [(-m | --max-matches) MAX]\n";
    print "             PATTERN [STRING ...]\n";
}

sub die_err {
    my ($code, $msg) = @_;
    print STDERR "$msg\n";
    exit $code;
}

# Print capture groups, filtering out undefined values
sub print_groups {
    my (@groups) = @_;
    print "$_\n" for grep { defined } @groups;
}

# Print match results based on options
sub print_results {
    my ($str, $result_ref, $indices_ref, $pattern, $opts) = @_;
    my @result = @$result_ref;

    # With --invert or --entire, print the entire string
    if ($opts->invert || $opts->entire) {
        if ($opts->index) {
            print "1 " . length($str) . "\n";
        } else {
            print "$str\n";
        }
        # With --entire (but not --invert), also print capture groups
        if ($opts->entire && !$opts->invert && @result > 1 && !$opts->groups_only) {
            my (undef, @matches) = @result;
            print_groups(@matches);
        }
        return 1;
    }

    # Handle --index
    if ($opts->index) {
        if ($opts->all) {
            my @indices = do_match($str, $pattern, $opts->ignore_case, 1, 1);
            print "$_\n" for @indices;
        } else {
            print "$_\n" for @$indices_ref;
        }
        return 1;
    }

    # Handle --groups-only
    if ($opts->groups_only) {
        my @matches;
        if ($opts->all) {
            @matches = do_match($str, $pattern, $opts->ignore_case, 1, 0);
        } elsif (@result > 1) {
            (undef, @matches) = @result;
        }

        @matches = grep { defined && length } @matches;

        if (@matches) {
            print "$_\n" for @matches;
            return 1;
        } else {
            return 0;  # No valid capture groups
        }
    }

    # Handle capture groups
    if (@result > 1) {
        my ($full_match, @matches) = @result;
        print "$full_match\n" if defined $full_match;
        print_groups(@matches);
        return 1;
    }

    # Handle regular matches
    if ($opts->all) {
        my @matches = do_match($str, $pattern, $opts->ignore_case, 1, 0);
        print "$_\n" for @matches;
    } else {
        print "$result[0]\n" if defined $result[0];
    }
    return 1;
}

# Convert glob pattern to regex
sub glob_to_regex {
    my ($pattern) = @_;
    # Escape special regex characters except * and ?
    $pattern =~ s/([\.\^\$\(\)\{\}\+\|\\])/\\$1/g;
    # Convert glob wildcards to regex
    $pattern =~ s/\*/\.\*/g;
    $pattern =~ s/\?/\./g;
    return $pattern;
}

# Perform regex match and return full match + capture groups (if any)
sub do_match {
    my ($str, $pattern, $ignore_case, $global, $with_index) = @_;
    my $flags = '';
    $flags .= '(?i)' if $ignore_case;
    my $re = qr/${flags}${pattern}/;

    if ($global) {
        if ($with_index) {
            # For global with index, we need to track all match positions and lengths
            my @results = ();
            while ($str =~ /$re/g) {
                my $idx = $-[0] + 1;  # 1-based index
                my $len = $+[0] - $-[0];  # length of match
                push @results, "$idx $len";
            }
            return @results;
        } else {
            # For global matching, return all matches (or capture groups if present)
            my @results = ();
            while ($str =~ /$re/g) {
                # If there are capture groups, collect them
                if ($#- > 0) {
                    for my $i (1 .. $#-) {
                        push @results, substr($str, $-[$i], $+[$i] - $-[$i]);
                    }
                } else {
                    # No capture groups, just the full match
                    push @results, $&;
                }
            }
            return @results;
        }
    } elsif ($str =~ /$re/) {
        # Return full match plus any capture groups
        my @groups = ($&);
        my @indices = ();

        if ($with_index) {
            # Collect 1-based indices and lengths for full match and capture groups
            for my $i (0 .. $#-) {
                my $idx = $-[$i] + 1;  # 1-based index
                my $len = $+[$i] - $-[$i];  # length
                push @indices, "$idx $len";
            }
        }

        for my $i (1 .. $#-) {
            push @groups, substr($str, $-[$i], $+[$i] - $-[$i]);
        }

        return $with_index ? (\@groups, \@indices) : @groups;
    }
    return ();
}

# Parse options
my $opts = MatchOptions->new();

GetOptions(
    'a|all'           => \$opts->{all},
    'e|entire'        => \$opts->{entire},
    'g|groups-only'   => \$opts->{groups_only},
    'h|help'          => \$opts->{help},
    'i|ignore-case'   => \$opts->{ignore_case},
    'n|index'         => \$opts->{index},
    'm|max-matches=i' => \$opts->{max_matches},
    'q|quiet'         => \$opts->{quiet},
    'r|regex'         => \$opts->{regex},
    'v|invert'        => \$opts->{invert},
) or die_err(2, "string match: invalid option");

# Act on help flag
if ($opts->help) {
    usage();
    exit 0;
}

# Check for invalid option combinations
my @exclusive_pairs = (
    ['entire', 'groups_only'],
    ['invert', 'groups_only'],
);

for my $pair (@exclusive_pairs) {
    my ($opt1, $opt2) = @$pair;
    if ($opts->$opt1 && $opts->$opt2) {
        my $flag1 = $opt1 =~ s/_/-/gr;
        my $flag2 = $opt2 =~ s/_/-/gr;
        die_err(2, "string match: invalid option combination, --$flag1 and --$flag2 are mutually exclusive");
    }
}

# Check for unimplemented options
# (none currently)

# Must have at least a pattern
die_err(2, "string match: missing PATTERN.") if @ARGV == 0;

my $pattern = shift @ARGV;

# Convert glob to regex if not using --regex
if (!$opts->regex) {
    $pattern = glob_to_regex($pattern);
    # Without --entire, anchor the pattern to match whole string
    $pattern = "^${pattern}\$" unless $opts->entire;
}

# Determine input source: piped stdin or command line args
my $use_stdin = (!-t STDIN && @ARGV == 0);

# If no strings provided and no stdin, nothing to match
exit 1 if !$use_stdin && @ARGV == 0;

# Process each string
my $match_found = 0;
my $matches_count = 0;

# Set up input iterator
my $get_next_str = $use_stdin
    ? sub { my $line = <STDIN>; chomp $line if defined $line; return $line; }
    : sub { return shift @ARGV; };

while (defined(my $str = $get_next_str->())) {
    # Apply the pattern match
    my @result;
    my $indices_ref;

    if ($opts->index && !$opts->invert) {
        ($result[0], $indices_ref) = do_match($str, $pattern, $opts->ignore_case, 0, 1);
        @result = @{$result[0]} if $result[0];
    } else {
        @result = do_match($str, $pattern, $opts->ignore_case, 0, 0);
    }

    # Handle --invert
    my $matched = @result ? 1 : 0;
    $matched = !$matched if $opts->invert;

    next unless $matched;

    $match_found = 1;
    $matches_count++;

    # With --quiet, exit immediately on first match
    exit 0 if $opts->quiet;

    # Check if we've reached max matches
    if ($opts->max_matches && $matches_count >= $opts->max_matches) {
        # Print current result before exiting
        print_results($str, \@result, $indices_ref, $pattern, $opts);
        exit 0;
    }

    # Print results and check if we actually printed anything (for --groups-only)
    my $printed = print_results($str, \@result, $indices_ref, $pattern, $opts);

    # If nothing was printed (e.g., no valid capture groups), don't count as match
    if (!$printed) {
        $match_found = 0;
        $matches_count--;
        next;
    }
}

exit($match_found ? 0 : 1);
