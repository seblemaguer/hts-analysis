#!/usr/bin/perl

################################################################################
## get_path.pl
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

################################################################################


my $flagHelp = 0;
my $flagLabel = 0;
my $state= 2;
GetOptions('h|help' => \$flagHelp,'l|label' => \$flagLabel, 's|state=i' => \$state);


################################################################################

sub usage()
{
	print <<EOF;
Usage:
	revert_search.pl <tree_file> <label>
Synopsis:
	
Options:
	-h, --help
	-s, --state 	state_id		[2]
EOF
}


################################################################################

####
#  sub extract_header
#
#  Function used to associates the answers to the questions of the decision
#  tree. Useless lines are removed until the tree of the given state (programm)
#  is reached
#
#  param[in]:
#    - $lines = lines of the file (reference on a list)
#
#  return the questions hashtable which associates a list of regexp (answers) to
#  a question id
##
sub extract_header
{
    my ($lines) = @_;

    my $stop = 0;
    my %questions = ();

    while ($stop == 0)
    {
        # Question lines
        if ((!defined($lines->[0]))) {
            die "state $state does not exist";
        }
        if ($lines->[0] =~ /^QS/)
        {
            my @cur_line = split(/ /, $lines->[0]);
            my $name = $cur_line[1]; # Nom de la question
            my @answers = split(/,/, $cur_line[3]);

            # Adapt the answers to perl regexp
            for (my $i=0; $i<@answers; $i++)
            {
                $answers[$i] =~ s/"//g;
                $answers[$i] =~ s/\*/.*/g;
                $answers[$i] =~ s/\+/\\+/g;
                $answers[$i] =~ s/\?/\\?/g;
                $answers[$i] =~ s/\-/\\-/g;
                $answers[$i] =~ s/\^/\\^/g;
            }

            # Add the question
            @{$questions{$name}} = @answers;
            shift(@{$lines});


            # # <DEBUG>
            # print "====== $name =====\n";
            # foreach my $ans (@answers)
            # {
            #     print "  -  $ans\n";
            # }
            # print "\n";
            # # </DEBUG>
        }
        
        # Empty lines
        elsif (($lines->[0] =~ /.*\[$state\]\.stream/) or ($lines->[0] =~ /.*\[$state\]$/))
        {
            $stop = 1;
        }

        # Useless lines
        else
        {
            shift(@{$lines});
        }
    }

    return %questions;
}


####
#  sub generate_tree
#
#  Function used to generate the tree. The is only an array of arrays. The
#  second level array contains 3 elements: the node name, the left node index,
#  the right node index. By using the name, we can find the regexp of answers in
#  the previously generated question hashtable
#
#  param[in]:
#    - $lines = lines of the file (reference on a list)
#
#  return the tree in a list data structure
##
sub generate_tree
{
    my ($lines) = @_;

    # Delete cur_tree header
    shift(@{$lines});
    shift(@{$lines});
    my @tree = ();

    # Extract sub_part
    while ($lines->[0] !~ /^\}$/) 
    {
        my @cur_line = split(/[\s\t]+/, $lines->[0]);

        # Current node
        my $index = -$cur_line[1];
        my $name = $cur_line[2];

        # Left node
        my $left = $cur_line[3];
        if ($left =~ /\d+\z/) # integer? => node
        {
            $left = -$left;
        }
        else
        {
            $left =~ s/"//g;
        }

        # Right node
        my $right = $cur_line[4];
        if ($right =~ /\d+\z/)  # integer? => node
        {
            $right = -$right;
        }
        else
        {
            $right =~ s/"//g;
        }

        # Add thee node to the tree (store in a table way)
        shift(@{$lines});
        %{$tree[$index]} = (name=>$name, left=>$left, right=>$right);
    }

    
    # # <DEBUG>
    # for (my $i=1; $i<@tree; $i++)
    # {
    #     print "index = $i, name = ".$tree[$i]->{name}.", left = ".$tree[$i]->{left}.", right = ".$tree[$i]->{right}."\n";
    # }
    # # </DEBUG>

    return @tree;
}



####
#  sub get_path
#
#  Function used to find the path of a list of labels in the loaded tree
#
#  param[in]:
#    - $refQuest = reference on the question hashtable
#    - $refTree = reference on the tree
#    - $label = label whose path is going to be search
#
##
sub get_path_rec
{
    my ($refQuest, $refTree, $label, $start) = @_;
    my @results = ();

    # Node => check the subtree
    if ($start =~ /^\d+\z$/)
    {
        my $next_node = $refTree->[$start]->{right};
        my $name = $refTree->[$start]->{name};
        my @rec_res = get_path_rec($refQuest, $refTree, $label, $next_node);
        if (@rec_res > 0)
        {
            push(@results, @rec_res);
            push(@results,  "$name");
        }
        else
        {
            $next_node = $refTree->[$start]->{left};
            @rec_res = get_path_rec($refQuest, $refTree, $label, $next_node);
            if (@rec_res > 0)
            {
                push(@results, @rec_res);
                push(@results,  "!($name)");
            }
        }
    }
    # Leaf => check the name
    elsif ($label eq $start)
    {
        @results = ($label);
    }

    return @results;
}

####
#  sub get_path
#
#  Function used to find the path of a list of labels in the loaded tree
#
#  param[in]:
#    - $refQuest = reference on the question hashtable
#    - $refTree = reference on the tree
#    - $label = label whose path is going to be search
#
##
sub get_path
{
    my ($refQuest, $refTree, $label) = @_;
    print "$label : ";
    my @results = get_path_rec($refQuest, $refTree, $label, 0);
    for my $i (0..$#results-2)
    {
        printf "$results[$#results-$i] => ";
    }
    
    # End of the tree!
    if ($#results == -1)
    {
        print "/\n";
    }
    else
    {
        printf "$results[1]\n";
    }
}

################################################################################


if (($flagHelp) or (@ARGV != 2))
{
	die usage();
}


open(TREE_FILE, "$ARGV[0]") or die("cannot open $ARGV[0]: $!");
my @lines = <TREE_FILE>;
close(TREE_FILE);

my %questions = extract_header(\@lines);
my @tree = generate_tree(\@lines);

get_path(\%questions, \@tree, $ARGV[1]);
