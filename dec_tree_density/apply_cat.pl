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
    @{$cat_hash{p1}} = ("C-Vowel", "C-Consonant", "C-Stop", "C-Nasal", "C-Fricative", "C-Liquid", "C-Front", "C-Central", "C-Back", "C-Front_Vowel", "C-Central_Vowel", "C-Back_Vowel", "C-Long_Vowel", "C-Short_Vowel", "C-Dipthong_Vowel", "C-Front_Start_Vowel", "C-Fronting_Vowel", "C-High_Vowel", "C-Medium_Vowel", "C-Low_Vowel", "C-Rounded_Vowel", "C-Unrounded_Vowel", "C-Reduced_Vowel", "C-IVowel", "C-EVowel", "C-AVowel", "C-OVowel", "C-UVowel", "C-Unvoiced_Consonant", "C-Voiced_Consonant", "C-Front_Consonant", "C-Central_Consonant", "C-Back_Consonant", "C-Fortis_Consonant", "C-Lenis_Consonant", "C-Neigther_F_or_L", "C-Coronal_Consonant", "C-Non_Coronal", "C-Anterior_Consonant", "C-Non_Anterior", "C-Continuent", "C-No_Continuent", "C-Positive_Strident", "C-Negative_Strident", "C-Neutral_Strident", "C-Glide", "C-Syllabic_Consonant", "C-Voiced_Stop", "C-Unvoiced_Stop", "C-Front_Stop", "C-Central_Stop", "C-Back_Stop", "C-Voiced_Fricative", "C-Unvoiced_Fricative", "C-Front_Fricative", "C-Central_Fricative", "C-Back_Fricative", "C-Affricate_Consonant", "C-Not_Affricate", "C-silences", "C-aa", "C-ae", "C-ah", "C-ao", "C-aw", "C-ax", "C-axr", "C-ay", "C-b", "C-ch", "C-d", "C-dh", "C-dx", "C-eh", "C-el", "C-em", "C-en", "C-er", "C-ey", "C-f", "C-g", "C-hh", "C-hv", "C-ih", "C-iy", "C-jh", "C-k", "C-l", "C-m", "C-n", "C-nx", "C-ng", "C-ow", "C-oy", "C-p", "C-r", "C-s", "C-sh", "C-t", "C-th", "C-uh", "C-uw", "C-v", "C-w", "C-y", "C-z", "C-zh", "C-pau", "C-h#", "C-brth");
    @{$cat_hash{p3}} = ("[LR]-Vowel", "[LR]-Consonant", "[LR]-Stop", "[LR]-Nasal", "[LR]-Fricative", "[LR]-Liquid", "[LR]-Front", "[LR]-Central", "[LR]-Back", "[LR]-Front_Vowel", "[LR]-Central_Vowel", "[LR]-Back_Vowel", "[LR]-Long_Vowel", "[LR]-Short_Vowel", "[LR]-Dipthong_Vowel", "[LR]-Front_Start_Vowel", "[LR]-Fronting_Vowel", "[LR]-High_Vowel", "[LR]-Medium_Vowel", "[LR]-Low_Vowel", "[LR]-Rounded_Vowel", "[LR]-Unrounded_Vowel", "[LR]-Reduced_Vowel", "[LR]-IVowel", "[LR]-EVowel", "[LR]-AVowel", "[LR]-OVowel", "[LR]-UVowel", "[LR]-Unvoiced_Consonant", "[LR]-Voiced_Consonant", "[LR]-Front_Consonant", "[LR]-Central_Consonant", "[LR]-Back_Consonant", "[LR]-Fortis_Consonant", "[LR]-Lenis_Consonant", "[LR]-Neigther_F_or_L", "[LR]-Coronal_Consonant", "[LR]-Non_Coronal", "[LR]-Anterior_Consonant", "[LR]-Non_Anterior", "[LR]-Continuent", "[LR]-No_Continuent", "[LR]-Positive_Strident", "[LR]-Negative_Strident", "[LR]-Neutral_Strident", "[LR]-Glide", "[LR]-Syllabic_Consonant", "[LR]-Voiced_Stop", "[LR]-Unvoiced_Stop", "[LR]-Front_Stop", "[LR]-Central_Stop", "[LR]-Back_Stop", "[LR]-Voiced_Fricative", "[LR]-Unvoiced_Fricative", "[LR]-Front_Fricative", "[LR]-Central_Fricative", "[LR]-Back_Fricative", "[LR]-Affricate_Consonant", "[LR]-Not_Affricate", "[LR]-silences", "[LR]-aa", "[LR]-ae", "[LR]-ah", "[LR]-ao", "[LR]-aw", "[LR]-ax", "[LR]-axr", "[LR]-ay", "[LR]-b", "[LR]-ch", "[LR]-d", "[LR]-dh", "[LR]-dx", "[LR]-eh", "[LR]-el", "[LR]-em", "[LR]-en", "[LR]-er", "[LR]-ey", "[LR]-f", "[LR]-g", "[LR]-hh", "[LR]-hv", "[LR]-ih", "[LR]-iy", "[LR]-jh", "[LR]-k", "[LR]-l", "[LR]-m", "[LR]-n", "[LR]-nx", "[LR]-ng", "[LR]-ow", "[LR]-oy", "[LR]-p", "[LR]-r", "[LR]-s", "[LR]-sh", "[LR]-t", "[LR]-th", "[LR]-uh", "[LR]-uw", "[LR]-v", "[LR]-w", "[LR]-y", "[LR]-z", "[LR]-zh", "[LR]-pau", "[LR]-h#", "[LR]-brth");
    @{$cat_hash{p5}} = ("[LR][LR]-Vowel", "[LR][LR]-Consonant", "[LR][LR]-Stop", "[LR][LR]-Nasal", "[LR][LR]-Fricative", "[LR][LR]-Liquid", "[LR][LR]-Front", "[LR][LR]-Central", "[LR][LR]-Back", "[LR][LR]-Front_Vowel", "[LR][LR]-Central_Vowel", "[LR][LR]-Back_Vowel", "[LR][LR]-Long_Vowel", "[LR][LR]-Short_Vowel", "[LR][LR]-Dipthong_Vowel", "[LR][LR]-Front_Start_Vowel", "[LR][LR]-Fronting_Vowel", "[LR][LR]-High_Vowel", "[LR][LR]-Medium_Vowel", "[LR][LR]-Low_Vowel", "[LR][LR]-Rounded_Vowel", "[LR][LR]-Unrounded_Vowel", "[LR][LR]-Reduced_Vowel", "[LR][LR]-IVowel", "[LR][LR]-EVowel", "[LR][LR]-AVowel", "[LR][LR]-OVowel", "[LR][LR]-UVowel", "[LR][LR]-Unvoiced_Consonant", "[LR][LR]-Voiced_Consonant", "[LR][LR]-Front_Consonant", "[LR][LR]-Central_Consonant", "[LR][LR]-Back_Consonant", "[LR][LR]-Fortis_Consonant", "[LR][LR]-Lenis_Consonant", "[LR][LR]-Neigther_F_or_L", "[LR][LR]-Coronal_Consonant", "[LR][LR]-Non_Coronal", "[LR][LR]-Anterior_Consonant", "[LR][LR]-Non_Anterior", "[LR][LR]-Continuent", "[LR][LR]-No_Continuent", "[LR][LR]-Positive_Strident", "[LR][LR]-Negative_Strident", "[LR][LR]-Neutral_Strident", "[LR][LR]-Glide", "[LR][LR]-Syllabic_Consonant", "[LR][LR]-Voiced_Stop", "[LR][LR]-Unvoiced_Stop", "[LR][LR]-Front_Stop", "[LR][LR]-Central_Stop", "[LR][LR]-Back_Stop", "[LR][LR]-Voiced_Fricative", "[LR][LR]-Unvoiced_Fricative", "[LR][LR]-Front_Fricative", "[LR][LR]-Central_Fricative", "[LR][LR]-Back_Fricative", "[LR][LR]-Affricate_Consonant", "[LR][LR]-Not_Affricate", "[LR][LR]-silences", "[LR][LR]-aa", "[LR][LR]-ae", "[LR][LR]-ah", "[LR][LR]-ao", "[LR][LR]-aw", "[LR][LR]-ax", "[LR][LR]-axr", "[LR][LR]-ay", "[LR][LR]-b", "[LR][LR]-ch", "[LR][LR]-d", "[LR][LR]-dh", "[LR][LR]-dx", "[LR][LR]-eh", "[LR][LR]-el", "[LR][LR]-em", "[LR][LR]-en", "[LR][LR]-er", "[LR][LR]-ey", "[LR][LR]-f", "[LR][LR]-g", "[LR][LR]-hh", "[LR][LR]-hv", "[LR][LR]-ih", "[LR][LR]-iy", "[LR][LR]-jh", "[LR][LR]-k", "[LR][LR]-l", "[LR][LR]-m", "[LR][LR]-n", "[LR][LR]-nx", "[LR][LR]-ng", "[LR][LR]-ow", "[LR][LR]-oy", "[LR][LR]-p", "[LR][LR]-r", "[LR][LR]-s", "[LR][LR]-sh", "[LR][LR]-t", "[LR][LR]-th", "[LR][LR]-uh", "[LR][LR]-uw", "[LR][LR]-v", "[LR][LR]-w", "[LR][LR]-y", "[LR][LR]-z", "[LR][LR]-zh", "[LR][LR]-pau", "[LR][LR]-h#", "[LR][LR]-brth");

    # Syllable
    @{$cat_hash{"syl-prosody"}} = ("L-Syl_Stress", "C-Syl_Stress", "R-Syl_Stress",
                                "L-Syl_Accent", "C-Syl_Accent", "R-Syl_Accent",
                                "Num-StressedSyl_before_C-Syl_in_C-Phrase", "Num-StressedSyl_after_C-Syl_in_C-Phrase",
                                "Num-AccentedSyl_before_C-Syl_in_C-Phrase", "Num-AccentedSyl_after_C-Syl_in_C-Phrase",
                                "Num-Syl_from_prev-StressedSyl", "Num-Syl_from_next-StressedSyl",
                                "Num-Syl_from_prev-AccentedSyl", "Num-Syl_from_next-AccentedSyl",

                                  # Vowel part
                                "C-Syl_Vowel", "C-Syl_Front_Vowel", "C-Syl_Central_Vowel", "C-Syl_Back_Vowel", "C-Syl_Long_Vowel", "C-Syl_Short_Vowel", "C-Syl_Dipthong_Vowel", "C-Syl_Front_Start", "C-Syl_Fronting_Vowel", "C-Syl_High_Vowel", "C-Syl_Medium_Vowel", "C-Syl_Low_Vowel", "C-Syl_Rounded_Vowel", "C-Syl_Unrounded_Vowel", "C-Syl_Reduced_Vowel", "C-Syl_IVowel", "C-Syl_EVowel", "C-Syl_AVowel", "C-Syl_OVowel", "C-Syl_UVowel", "C-Syl_aa", "C-Syl_ae", "C-Syl_ah", "C-Syl_ao", "C-Syl_aw", "C-Syl_ax", "C-Syl_axr", "C-Syl_ay", "C-Syl_eh", "C-Syl_el", "C-Syl_em", "C-Syl_en", "C-Syl_er", "C-Syl_ey", "C-Syl_ih", "C-Syl_iy", "C-Syl_ow", "C-Syl_oy", "C-Syl_uh", "C-Syl_uw"
                               );
    @{$cat_hash{"syl-position"}} = ("Seg_Fw", "SegBw",
                                  "L-Syl_Num-Segs", "C-Syl_Num-Segs", "C-Syl_Num-Segs",
                                  "Pos_C-Syl_in_C-Word(Fw)", "Pos_C-Syl_in_C-Word(Bw)",
                                  "Pos_C-Syl_in_C-Phrase(Fw)", "Pos_C-Syl_in_C-Phrase(Bw)");

    @{$cat_hash{"syl-surprisal"}} = ("C-Syl_Surp");

    # Word
    @{$cat_hash{"word-prosody"}} = ("L-Word_GPOS", "C-Word_GPOS", "R-Word_GPOS",
                               "Num-ContWord_before_C-Word_in_C-Phrase", "Num-ContWord_after_C-Word_in_C-Phrase",
                               "Num-Words_from_prev-ContWord", "Num-Words_from_next-ContWord");
    @{$cat_hash{"word-position"}} = ("L-Word_Num-Syls", "C-Word_Num-Syls", "R-Word_Num-Syls", "Pos_C-Word_in_C-Phrase(Fw)", "Pos_C-Word_in_C-Phrase(Bw)");

    # Syntax
    @{$cat_hash{"phrase-prosody"}} = ("L-Phrase_Num-Syls", "C-Phrase_Num-Syls", "R-Phrase_Num-Syls",
                                  "L-Phrase_Num-Words", "C-Phrase_Num-Words", "R-Phrase_Num-Words",
                                  "Pos_C-Phrase_in_Utterance(Fw)", "Pos_C-Phrase_in_Utterance(Bw)");
    @{$cat_hash{"phrase-position"}} = ("C-Phrase_TOBI_End-tone");


    # UTT
    @{$cat_hash{"utterance"}} = ("Num-Syls_in_Utterance", "Num-Words_in_Utterance", "Num-Phrases_in_Utterance");

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
