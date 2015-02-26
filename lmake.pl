#!/usr/bin/perl

use strict;
use warnings;

my $MAIN = $ENV{'HOME'} . '/lmake/';
my $CFG = $MAIN . 'config';

my $file = shift @ARGV;
if (!defined $file) {
    die "please specify a target file";
}
my $mode = '';
if (@ARGV) {
    $mode = shift @ARGV;
}

if ($file !~ /^(.*)(\.[^\.]*)$/) {
    die "the file should have an extension";
}
my ($name, $ext) = ($1, $2);

sub esc {
    my ($a) = @_;
    $a =~ s/'/''/g;
    return "'$a'";
}

my $efile = esc($file);
my $ename = esc($name);

if (!-e $file) {
    my $def = "$MAIN/default$ext";
    if (!-e $def) {
        die "no default $ext file";
    }
    system 'cp ' . esc($def) . " $efile";
    print "$file created\n";
    exit;
}

my $state = 0;
my $found = 0;
my $prefix;
open my $fh, '<', $CFG;
while (my $line = <$fh>) {
    chomp $line;
    if ($state == 0) {
        if ($line =~ /^\./) {
            if (grep {$_ eq $ext} (split /,/, $line)) {
                $found = 1;
            }
            $state = 1;
        }
    } elsif ($state == 1) {
        $prefix = $line;
        $state = 2;
    } elsif ($state == 2) {
        if ($line =~ /(.*?):(.*)/) {
            if ($found && $1 eq $mode) {
                system "f(){ $prefix $2 };f $efile $ename";
                close $fh;
                exit;
            }
        } else {
            if ($found) {
                last;
            }
            $state = 0;
        }
    }
}
close $fh;

if ($found) {
    die "no configuration for $ext mode \"$mode\" found";
}
die "no configuration for $ext found";
