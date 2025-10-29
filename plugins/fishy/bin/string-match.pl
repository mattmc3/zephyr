#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);

sub usage {
    print "string match [-a | --all] [-e | --entire] [-i | --ignore-case]\n";
    print "             [-g | --groups-only] [-r | --regex] [-n | --index]\n";
    print "             [-q | --quiet] [-v | --invert]\n";
    print "             PATTERN [STRING ...]\n";
}

sub die_err {
    my ($code, $msg) = @_;
    print STDERR "$msg\n";
    exit $code;
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
            return $str =~ /$re/g;
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
my ($opt_all, $opt_entire, $opt_help, $opt_ignore_case, $opt_groups_only);
my ($opt_regex, $opt_index, $opt_invert, $opt_quiet);

GetOptions(
    'a|all'         => \$opt_all,
    'e|entire'      => \$opt_entire,
    'g|groups-only' => \$opt_groups_only,
    'h|help'        => \$opt_help,
    'i|ignore-case' => \$opt_ignore_case,
    'n|index'       => \$opt_index,
    'q|quiet'       => \$opt_quiet,
    'r|regex'       => \$opt_regex,
    'v|invert'      => \$opt_invert,
) or die_err(2, "string match: invalid option");

# Act on help flag
if ($opt_help) {
    usage();
    exit 0;
}

# Check for unimplemented options
die_err(1, "-g/--groups-only option not yet implemented.") if $opt_groups_only;

# Collect piped input if present
if (!-t STDIN) {
    while (my $line = <STDIN>) {
        chomp $line;
        push @ARGV, $line;
    }
}

# Must have at least a pattern
die_err(2, "string match: missing PATTERN.") if @ARGV == 0;

my $pattern = shift @ARGV;

# Convert glob to regex if not using --regex
$pattern = glob_to_regex($pattern) unless $opt_regex;

# If no strings provided, nothing to match
exit 1 if @ARGV == 0;

# Process each string
my $match_found = 0;

foreach my $str (@ARGV) {
    # Apply the pattern match
    my @result;
    my $indices_ref;

    if ($opt_index) {
        ($result[0], $indices_ref) = do_match($str, $pattern, $opt_ignore_case, 0, 1);
        @result = @{$result[0]} if $result[0];
    } else {
        @result = do_match($str, $pattern, $opt_ignore_case, 0, 0);
    }

    # Handle --invert
    my $matched = @result ? 1 : 0;
    $matched = !$matched if $opt_invert;

    next unless $matched;

    $match_found = 1;
    next if $opt_quiet;

    # With --invert or --entire, print the entire string
    if ($opt_invert || $opt_entire) {
        print "$str\n";
    } elsif ($opt_index) {
        # Print indices instead of matches
        if ($opt_all) {
            # For --all with --index, get all match positions
            my @indices = do_match($str, $pattern, $opt_ignore_case, 1, 1);
            print "$_\n" for @indices;
        } else {
            print "$_\n" for @{$indices_ref};
        }
    } elsif (@result > 1) {
        # Pattern has capture groups - print full match then groups
        my ($full_match, @matches) = @result;
        print "$full_match\n" if defined $full_match;
        print "$_\n" for grep { defined } @matches;
    } else {
        # No capture groups - print matched portion(s)
        if ($opt_all) {
            my @matches = do_match($str, $pattern, $opt_ignore_case, 1, 0);
            print "$_\n" for @matches;
        } else {
            print "$result[0]\n" if defined $result[0];
        }
    }
}

exit($match_found ? 0 : 1);
