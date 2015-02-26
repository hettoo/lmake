#!/usr/bin/perl

use strict;
use warnings;

my $MAIN = $ENV{'HOME'} . '/lmake/';

my $file = shift @ARGV;
if (!defined $file) {
    die "please specify a target file";
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

sub progress {
    if (@ARGV) {
        unshift @ARGV, $file;
        exec $^X, $0, @ARGV or die $!;
    } else {
        exit;
    }
}

if (!-e $file) {
    my $def = "$MAIN/default$ext";
    if (!-e $def) {
        die "no default $ext file";
    }
    (system 'cp ' . esc($def) . " $efile") == 0 or die $!;
    print "$file created\n";
    progress();
}

my $action = '';
if (@ARGV) {
    $action = shift @ARGV;
}

my $state = 0;
my $found = 0;
my $prefix;
open my $fh, '<', $MAIN . 'config';
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
            if ($found && $1 eq $action) {
                (system "f(){ $prefix $2 };f $efile $ename") == 0 or die $!;
                close $fh;
                progress();
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
    die "no configuration for $ext action \"$action\" found";
}
die "no configuration for $ext found";
