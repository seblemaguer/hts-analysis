#!/usr/bin/perl

################################################################################
## model_statistics.pl
##
## Copyright 2011 Sébastien Le Maguer(Sebastien.Le_maguer@irisa.fr)
##
################################################################################

# [FLYMAKE]
use lib "../../../ext/perl";
use lib "../../perl";
# [/FLYMAKE]


use lib "../ext/perl";
use lib "perl";
use lib "analysis/trees";

use strict;
use warnings;
use Getopt::Long;
use Log::Handler;

use tree;
################################################################################


my $flagHelp = 0;
my $LogFilename = '';
my $flagLog = 0;
my $nbstate = 5;
GetOptions('h|help' => \$flagHelp,'l|log=s' => \$LogFilename, 'n|nbstate=s' => \$nbstate);


my $log = Log::Handler->new();
$log->add(screen => {log_to   => 'STDERR',newline  => 1,maxlevel => 'info'});

################################################################################

sub usage()
{
	print <<EOF;
Usage:
	model_statistics.pl <description_directory> <tree_directory><destination_directory>
Synopsis:
	
Options:
    -n, --nbstate					[5]
	-h, --help
	-l, --log							log_filename
EOF
}


################################################################################


if($LogFilename ne '')
{
	$log->add(file => {filename => $LogFilename,mode => 'append',autoflush => 1,newline  => 1,maxlevel => 7,minlevel => 0});
	$flagLog = 1;
}

if (($flagHelp) or (@ARGV != 3))
{
	die usage();
}

my %hash_counting = ();

################################################################################

sub init
	{

		$hash_counting{'mgc'} = ();
		$hash_counting{'lf0'} = ();
		$hash_counting{'bap'} = ();
		for (my $i=0; $i<=$nbstate-2; $i++) {
			$hash_counting{'mgc'}->[$i] = ();
			$hash_counting{'lf0'}->[$i] = ();
			$hash_counting{'bap'}->[$i] = ();
		}
	}

sub analyse_file
{
	my ($file) = @_;
	open(FILE, "$file") or die ("cannot open $file: $!\n");
	while (<FILE>)
	{
		my $line = $_;
		chomp($line);
		if ($line =~ /^\t\t/)
		{
			$line =~ s/^\t\t//;
			my @cur = split(/_/, $line);
			my @stream = split(/-/, $cur[2]);
			my $k = $cur[0];
			my $state = $cur[1];
			$state =~ s/s//;
			$state = $state - 2;
			$line = "$cur[0]_$cur[1]_$stream[0]";
			if (exists($hash_counting{$k}->[$state]->{$line}))
				{
					$hash_counting{$k}->[$state]->{$line} = $hash_counting{$k}->[$state]->{$line} + 1;
				}
			else
				{
					$hash_counting{$k}->[$state]->{$line} = 0;
				}
		}
	}
	close(FILE);
}

################################################################################
my $dir = $ARGV[0];
my @files = <$dir/*.lab>;
foreach my $file (@files)
{
	chomp($file);
	print "analyse du fichier $file\n";
	analyse_file($file);
}
my $tree_path = $ARGV[1];
mkdir("$ARGV[2]");
foreach my $k (keys(%hash_counting)) {
	my @tree = generate_tree("$tree_path/$k.inf.untied");
	mkdir("$ARGV[2]/$k");
	open(REPORT, ">$ARGV[2]/$k/report.txt") or die ("cannot open $ARGV[2]/$k/report.txt: $!");
	print REPORT "id_state;nb_total de modeles; nb de modeles vus\n";
	for (my $i=0; $i<=$nbstate-2; $i++)
	{
		my $state = $i+2;
		my $seen = 0;
		my $total = 0;
		open(FILE, ">$ARGV[2]/$k/$state") or die ("cannot open $ARGV[2]/$k/$state: $!\n");
		print FILE "ident;compt;path\n";
		foreach my $k2 (list_leaves($tree[$i]))
		{
			my $count = $hash_counting{$k}->[$i]->{$k2};
            my $path = '';  
            if (!defined($count))
            {
                $count = 0;
            }
            else
            {
				$seen = $seen +1;
                $path = retrieve_path($tree[$i], $k2);
				print FILE "$k2;$count;$path\n";
            }
			$total = $total + 1;
		}
		close(FILE);

		print REPORT "$state;$total;$seen\n";
	}
	close(REPORT);
}
