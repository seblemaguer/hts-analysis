#!/usr/bin/perl

################################################################################
## list_labels_for_model.pl
##
## Copyright 2011 Sébastien Le Maguer(Sebastien.Le_maguer@irisa.fr)
##
################################################################################

# [FLYMAKE]
use lib "../../../../ext/perl";
use lib "../../../perl";
# [/FLYMAKE]


use lib "../ext/perl";
use lib "perl";

use strict;
use warnings;
use Getopt::Long;
use Log::Handler;

################################################################################


my $flagHelp = 0;
my $LogFilename = undef;
my $flagLog = 0;
my $tiedFilename = undef;
GetOptions('h|help' => \$flagHelp,'l|log=s' => \$LogFilename, 't|tied=s'=>\$tiedFilename);


my $log = Log::Handler->new();
$log->add(screen => {log_to   => 'STDERR',newline  => 1,maxlevel => 'info'});

my %models_hash = ();
################################################################################

sub usage()
  {
	print <<EOF;
Usage:
	list_labels_for_model.pl <ascii mmf> <model_id>
Synopsis:
	
Options:
	-h, --help
	-l, --log	log filename
	-t, --tied	tiedlist filename
EOF
  }

sub add_label
  {
	my ($model, $label) = @_;

	if (!defined($models_hash{$model})) {
	  $models_hash{$model} = ();
	}

	$models_hash{$model}->{$label} = 1;
  }

sub parse_tied
  {
	my ($tied_fn) = @_;
	my %assoc = ();

	open(TIED, "$tied_fn") or die ("cannot open $tied_fn: $!");
	while (<TIED>) {
	  chomp($_);
	  my @list = split(/\s+/, $_);
	  if (@list == 2) {
		if (!defined($assoc{$list[1]})) {
		  $assoc{$list[1]} = ();
		}
		push(@{$assoc{$list[1]}}, $list[0]);
	  }
	}
	close(TIED);

	return %assoc;
  }

sub parse_mmf
  {
	my ($mmf_fn) = @_;
	open(MMF, "$mmf_fn") or die ("cannot open $mmf_fn: $!");

	my $in_hmm = 0;
	my $cur_lab = "";
	my $cur_model = "";
	while (<MMF>) {
	  chomp($_);
	  if ($_ =~ /^~h/) {
		$cur_lab = $_;
		$cur_lab =~ s/~h "//;
		$cur_lab =~ s/"//g;
	  } elsif ($in_hmm == 1) {
		if ($_ =~ /<ENDHMM>/) {
		  $in_hmm = 0;
		} elsif ($_ =~ /^~p/) {
		  $cur_model = $_;
		  $cur_model =~ s/~p "//;
		  $cur_model =~ s/"//g;
		  $cur_model =~ s/-.*//g;
		  add_label($cur_model, $cur_lab);
		}
	  } elsif ($_ =~ /<BEGINHMM>/) {
		$in_hmm = 1;
	  }
	}
	close(MMF);
  }


################################################################################


if ($LogFilename ne '') {
  $log->add(file => {filename => $LogFilename,mode => 'append',autoflush => 1,newline  => 1,maxlevel => 7,minlevel => 0});
  $flagLog = 1;
}

if (($flagHelp) or (@ARGV != 2)) {
  die usage();
}

parse_mmf($ARGV[0]);
my %assoc = ();
  if (defined($tiedFilename)) {
	%assoc = parse_tied($tiedFilename);
  }
if (defined($models_hash{$ARGV[1]})) {
  my @list = keys(%{$models_hash{$ARGV[1]}});
  foreach my $model (@list) {
	print "$model\n";
	if (defined($assoc{$model})) {
	  my @tied = @{$assoc{$model}};
	  foreach my $mod2 (@tied) {
		print "$mod2\n";
	  }
	}
  }
} else {
  print "le model n'est pas présent\n";
}
