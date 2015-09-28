#!/usr/bin/perl

################################################################################
## csv2mat.pl
##
## Copyright 2012 Sébastien Le Maguer(Sebastien.Le_maguer@irisa.fr)
##
################################################################################

# [FLYMAKE]
# [/FLYMAKE]


use lib "../ext/perl";
use lib "perl";

use strict;
use warnings;
use Getopt::Long;
use Log::Handler;

################################################################################

my $xorder = undef;
my $yorder = undef;
my $flagHelp = 0;
my $LogFilename = '';
my $flagLog = 0;
GetOptions('h|help' => \$flagHelp,'l|log=s' => \$LogFilename, 'x|xorder=s'=>\$xorder, 'y|yorder=s'=>\$yorder);


my $log = Log::Handler->new();
$log->add(screen => {log_to   => 'STDERR',newline  => 1,maxlevel => 'info'});

################################################################################

sub usage()
{
	print <<EOF;
Usage:
	csv2mat.pl
Synopsis:
	
Options:
	-h, --help
	-l, --log	log filename
	-x, --xorder a string value
	-y, --yorder a string value
EOF
}


################################################################################


if($LogFilename ne '')
{
	$log->add(file => {filename => $LogFilename,mode => 'append',autoflush => 1,newline  => 1,maxlevel => 7,minlevel => 0});
	$flagLog = 1;
}

if (($flagHelp) or (@ARGV != 1))
{
	die usage();
}


open(CSV, "$ARGV[0]") or die("cannot open $ARGV[0]: $!");
my @lines = <CSV>;
close(CSV);


my @xtics = ();
my @ytics = ();
my %xtic = ();
my %ytic = ();
my $cur_ylength = 0;
my $cur_xlength = 0;

if (defined($xorder))
{
    @xtics = split(/ /, $xorder);
    $cur_xlength = @xtics;
    for (my $i=0; $i<$cur_xlength; $i++)
    {
        $xtic{$xtics[$i]} = $i;
    }
}


if (defined($yorder))
{
    @ytics = split(/ /, $yorder);
    $cur_ylength = @ytics;
    for (my $i=0; $i<$cur_ylength; $i++)
    {
        $ytic{$ytics[$i]} = $i;
    }
}

my @values = ();

foreach my $line (@lines)
{
    chomp($line);
    my @list = split(/;/, $line);
    if (!defined($xorder))
    {
        if (!defined($xtic{$list[0]}))
        {
            $xtic{$list[0]} = $cur_xlength;
            $xtics[$cur_xlength] = $list[0];
            $cur_xlength++;
        }
    }
    
    if (!defined($yorder))
    {
        if (!defined($ytic{$list[1]}))
        {
            $ytic{$list[1]} = $cur_ylength;
            $ytics[$cur_ylength] = $list[1];
            $cur_ylength++;
        }
    }
    
    my $cur_xindex = $xtic{$list[0]};
    my $cur_yindex = $ytic{$list[1]};
    if (!defined($values[$cur_xindex]))
    {
        @{$values[$cur_xindex]} = ();
    }

    $values[$cur_xindex]->[$cur_yindex] = $list[2];
}

my $xoffset = 0;

for (my $i=0; $i<$cur_xlength; $i++)
{
    for (my $j=0; $j<$cur_ylength; $j++)
    {
        if (!defined($values[$i]->[$j]))
        {
            $values[$i]->[$j] = 0;
        }
        print($i.",$xtics[$i],".$j.",$ytics[$j],".$values[$i]->[$j]."\n");
        print($i.",$xtics[$i],".($j+1).",,".$values[$i]->[$j]."\n");
    }
    print "\n";
    
    for (my $j=0; $j<$cur_ylength; $j++)
    {
        print(($i+1).",,".$j.",$ytics[$j],".$values[$i]->[$j]."\n");
        print(($i+1).",,".($j+1).",,".$values[$i]->[$j]."\n");
    }
    print "\n";
}
