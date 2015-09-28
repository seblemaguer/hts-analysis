
#!/usr/bin/perl

################################################################################
## generate_all_stages.pl
##
## Copyright 2011 Sébastien Le Maguer(Sebastien.Le_maguer@irisa.fr)
##
################################################################################

# [FLYMAKE]

use lib "../../ext/perl";
use lib "../perl";
# [/FLYMAKE]


use lib "../ext/perl";
use lib "perl";

use strict;
use warnings;
use Getopt::Long;
use Log::Handler;
use File::Path;
use common;
use tree;

################################################################################

my $flagHelp = 0;
my $LogFilename = '';
my $flagLog = 0;
my $flagSeen = 0;
my $pgtype = 0;
my $flagFixedDuration = 0;
GetOptions('h|help' => \$flagHelp,'l|log=s' => \$LogFilename);

my $log = Log::Handler->new();
$log->add(screen => {log_to   => 'STDERR',newline  => 1,maxlevel => 'info'});
common::init($log);

my $config = undef;
my %stage_files = ();
################################################################################

sub usage()
{
	print <<EOF;
Usage:
	search_tree.pl <tree_file> <node_id>
Synopsis:

Options:
	-h, --help
	-l, --log		filename
EOF
}

################################################################################


if($LogFilename ne '')
{
	$log->add(file => {filename => $LogFilename,mode => 'append',autoflush => 1,newline  => 1,maxlevel => 7,minlevel => 0});
	$flagLog = 1;
}

if (($flagHelp) or (@ARGV != 2))
{
	die usage();
}

my @tree = generate_tree($ARGV[0]);

foreach my $tr (@tree)
{
	my $path = retrieve_path($tr, $ARGV[1]);
	if (defined($path))
	{
		print "$path\n";
	}
}
