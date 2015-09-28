#!/usr/bin/perl

################################################################################
## apply_cat.pl
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


my $flagHelp = 0;
my $LogFilename = '';
my $flagLog = 0;
GetOptions('h|help' => \$flagHelp,'l|log=s' => \$LogFilename);


my $log = Log::Handler->new();
$log->add(screen => {log_to   => 'STDERR',newline  => 1,maxlevel => 'info'});

################################################################################

sub usage()
{
	print <<EOF;
Usage:
	apply_cat.pl
Synopsis:
	
Options:
	-h, --help
	-l, --log	log filename
EOF
}

################################################################################

##
#  sub generate_cat_hash
#
#  Function which generates the hash to associate a list of questions with a specific categorie
#
#  return the generated hash of categories
##
sub generate_cat_hash
{
    my %cat_hash = ();

    # Phonology
    @{$cat_hash{p1}} = ("C-");
    @{$cat_hash{p3}} = ("L-", "R-"); 
    @{$cat_hash{p5}} = ("LL-", "RR-");

    # Syllable
    @{$cat_hash{syl_prosody}} = ("L-Syl_Stress", "C-Syl_Stress", "R-Syl_Stress",
                                "L-Syl_Accent", "C-Syl_Accent", "R-Syl_Accent",
                                "Num-StressedSyl_before_C-Syl_in_C-Phrase", "Num-StressedSyl_after_C-Syl_in_C-Phrase",
                                "Num-AccentedSyl_before_C-Syl_in_C-Phrase", "Num-AccentedSyl_after_C-Syl_in_C-Phrase",
                                "Num-Syl_from_prev-StressedSyl", "Num-Syl_from_next-StressedSyl",
                                "Num-Syl_from_prev-AccentedSyl", "Num-Syl_from_next-AccentedSyl",
                                
                                  # Vowel part
                                "C-Syl_Vowel", "C-Syl_Front_Vowel", "C-Syl_Central_Vowel", "C-Syl_Back_Vowel", "C-Syl_Long_Vowel", "C-Syl_Short_Vowel", "C-Syl_Dipthong_Vowel", "C-Syl_Front_Start", "C-Syl_Fronting_Vowel", "C-Syl_High_Vowel", "C-Syl_Medium_Vowel", "C-Syl_Low_Vowel", "C-Syl_Rounded_Vowel", "C-Syl_Unrounded_Vowel", "C-Syl_Reduced_Vowel", "C-Syl_IVowel", "C-Syl_EVowel", "C-Syl_AVowel", "C-Syl_OVowel", "C-Syl_UVowel", "C-Syl_aa", "C-Syl_ae", "C-Syl_ah", "C-Syl_ao", "C-Syl_aw", "C-Syl_ax", "C-Syl_axr", "C-Syl_ay", "C-Syl_eh", "C-Syl_el", "C-Syl_em", "C-Syl_en", "C-Syl_er", "C-Syl_ey", "C-Syl_ih", "C-Syl_iy", "C-Syl_ow", "C-Syl_oy", "C-Syl_uh", "C-Syl_uw"
                               );
    @{$cat_hash{syl_position}} = ("Seg_Fw", "SegBw",
                                  "L-Syl_Num-Segs", "C-Syl_Num-Segs", "C-Syl_Num-Segs",
                                  "Pos_C-Syl_in_C-Word(Fw)", "Pos_C-Syl_in_C-Word(Bw)",
                                  "Pos_C-Syl_in_C-Phrase(Fw)", "Pos_C-Syl_in_C-Phrase(Bw)");
    
    @{$cat_hash{syl_surp}} = ("C-Syl_Surp");
    
    # Word
    @{$cat_hash{word_prosody}} = ("L-Word_GPOS", "C-Word_GPOS", "R-Word_GPOS",
                               "Num-ContWord_before_C-Word_in_C-Phrase", "Num-ContWord_after_C-Word_in_C-Phrase",
                               "Num-Words_from_prev-ContWord", "Num-Words_from_next-ContWord");
    @{$cat_hash{word_position}} = ("L-Word_Num-Syls", "C-Word_Num-Syls", "R-Word_Num-Syls", "Pos_C-Word_in_C-Phrase(Fw)", "Pos_C-Word_in_C-Phrase(Bw)");
    
    # Syntax
    @{$cat_hash{synt_prosody}} = ("L-Phrase_Num-Syls", "C-Phrase_Num-Syls", "R-Phrase_Num-Syls",
                                  "L-Phrase_Num-Words", "C-Phrase_Num-Words", "R-Phrase_Num-Words",
                                  "Pos_C-Phrase_in_Utterance(Fw)", "Pos_C-Phrase_in_Utterance(Bw)");
    @{$cat_hash{synt_position}} = ("C-Phrase_TOBI_End-tone");
    

    # UTT
    @{$cat_hash{utt}} = ("Num-Syls_in_Utterance", "Num-Words_in_Utterance", "Num-Phrases_in_Utterance");
    
    return %cat_hash;
}

##
#  sub node_to_cat_count
#
#  Function which generate histogram of question categories used by HTS in a csv
#  formated output
#
#  param[in]:
#    - node_fn: the name of the file which contains used nodes histogram
#    - ref_cat_hash: the previously generated hash of categories
##
sub node_to_cat_count
{
    my ($node_fn, $ref_cat_hash) = @_;
    
    # Init result hash
    my @cat_list = keys(%{$ref_cat_hash});
    my %result_hash = ();
    foreach my $k (@cat_list)
    {
        $result_hash{$k} = 0;
    }
    
    # Analyse node file
    open(NODE_FILE, $node_fn) or die("cannot open $node_fn: $!");
    while (<NODE_FILE>)
    {
        my $line = $_;
        chomp($line);

        my ($name, $count) = split(/;/, $line);

        # Search the corresponding categorie
        my $cat_index =0;
        my $cat_found = 0;
        while (($cat_index < @cat_list) and (!$cat_found))
        {
            my $node_index = 0;
            my @node_list = @{$ref_cat_hash->{$cat_list[$cat_index]}};
            while (($node_index < @node_list) and (!$cat_found))
            {
                # Categorie is found!
                if ($name =~ $node_list[$node_index])
                {
                    $result_hash{$cat_list[$cat_index]} += $count;
                    $cat_found = 1;
                }
                $node_index++;
            }
            $cat_index++;
        }
    }
    close(NODE_FILE);

    foreach my $k (keys(%result_hash))
    {
        print "$k;$result_hash{$k}\n";
    }
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

my %cat_hash = generate_cat_hash();
node_to_cat_count($ARGV[0], \%cat_hash);
