#!/usr/bin/perl

# perl script to write one text file
# with all julia commands to run on darwin
# machines
# Claudia October 2016

use Getopt::Long;
use File::Path qw( make_path );
use strict;
use warnings;
use Carp;


my @xta = (0.000001, 0.001);
my @xtr = (0.001,0.01);
my @fta = (0.000001,0.00001,0.0001,0.001,0.01);
my @ftr = (0.00001);
my @ratio = (1,100,10000);
my @nf = (100,75,50,25);
my $runs = 1;

my $filename = "juliaCommands.txt";

open my $FHsc, ">$filename";

foreach my $a (@xta){
    foreach my $b (@xtr){
	foreach my $c (@fta){
	    foreach my $d (@ftr){
		foreach my $e (@ratio){
		    foreach my $f (@nf){
			print $FHsc "julia oneSnaq.jl $a $b $c $d $e $f $runs\n";
		    }
		}
	    }
	}
    }
}
close $FHsc;

