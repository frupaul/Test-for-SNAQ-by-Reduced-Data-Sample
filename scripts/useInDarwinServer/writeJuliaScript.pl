#!/usr/bin/perl

# perl script to write one julia script
# with parameters for ONE scenario
# of xta,xtr,fta,ftr,nf,ratio
# Claudia October 2016

use Getopt::Long;
use File::Path qw( make_path );
use strict;
use warnings;
use Carp;



# ================= parameters ======================
my $xta = 0.00001;
my $xtr = 0.001;
my $fta = 0.000001;
my $ftr = 0.00001;
my $ratio = 1;
my $nf = 100;
my $runs = 10;

# -------------- read arguments from command-line -----------------------
GetOptions( 'xta=f' => \$xta,
	    'xtr=f' => \$xtr,
	    'fta=f' => \$fta,
	    'ftr=f' => \$ftr,
	    'ratio=i' => \$ratio,
	    'nf=i' => \$nf,
	    'runs=i' => \$runs,
    );


my $script = "xta${xta}_xtr${xtr}_fta${fta}_ftr${ftr}_ratio${ratio}_nf${nf}.jl";
my $lta = $fta * $ratio;

open my $FHsc, ">$script";
print $FHsc "using PhyloNetworks;\n"; # need to have PhyloNetworks installed in all darwin
print $FHsc "tableCF = readTableCF(\"tableCF.txt\");\n";
print $FHsc "startingTree = readTopology(\"bestStartingTree.txt\");\n";
print $FHsc "Filename =  string(\"nf\",$nf,\"xta\",$xta,\"xtr\",$xtr,\"fta\",$fta,\"ftr\",$ftr,\"lta\",$lta,\"_snaq\");\n";
print $FHsc "Output = snaq!(startingTree, tableCF, Nfail = $nf,";
print $FHsc "ftolAbs = $fta, xtolRel = $xtr, xtolAbs = $xta, liktolAbs = $lta, runs = $runs, filename = Filename);\n";
close $FHsc;

