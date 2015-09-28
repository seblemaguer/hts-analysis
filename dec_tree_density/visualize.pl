#!/usr/bin/perl

use lib "../../../ext/perl";
use lib "../ext/perl";

use IO::File;
use Tree::Binary;

sub generate_tree
{
	my ($cur_node_index, $list,$level) = @_;
	my $tmp;

	my $tree = Tree::Binary->new($list->[$cur_node_index]->[0].":".$list->[$cur_node_index]->[1]);

	if ($list->[$cur_node_index]->[2] =~ /^-?\d+$/)
	{
		$tmp = generate_tree(-$list->[$cur_node_index]->[2], $list); 
		$tree->left($tmp);
	}
	else
	{
		$list->[$cur_node_index]->[2] =~ s/"//g;
		$tmp = Tree::Binary->new($list->[$cur_node_index]->[2]);
		$tree->left($tmp);
	}

	if ($list->[$cur_node_index]->[3] =~ /^-?\d+$/)
	{
		$tmp = generate_tree(-$list->[$cur_node_index]->[3], $list);
		$tree->right($tmp);
	}
	else
	{
		$list->[$cur_node_index]->[3] =~ s/"//g;
		$tmp = Tree::Binary->new($list->[$cur_node_index]->[3]);
		$tree->right($tmp);
	}

	return ($tree);
}

sub print_tree_rec
{
	my ($tree, $fh) = @_;
	
	my $val = $tree->value();
	if (!$tree->is_leaf())
	{
		my $valtmp = $tree->left()->value();
		$fh->print("\"$val\" -> \"$valtmp\";\n");
		$valtmp = $tree->right()->value();
		$fh->print("\"$val\" -> \"$valtmp\";\n");

		print_tree_rec($tree->left(), $fh) if (defined($tree->left()));
		print_tree_rec($tree->right(), $fh) if (defined($tree->right()));
		
	}
	else
	{
		$fh->print("\"$val\" [color=red, style=filled];\n");
	}
}

sub print_tree
{
	my ($tree, $fn) = @_;


	my $fh = new IO::File($fn, "w");

	$fh->print("digraph unix {\nsize=\"6,6\";\nnode [color=lightblue2, style=filled];\n");
	print_tree_rec($tree, $fh);
	$fh->print("}");

	$fh->close();
}

sub parse_file
{
	my ($filename) = @_;

	# Opening
	open(FILE, $filename) or die "cannot open $filename: $!";
	my @lines = <FILE>;
	close(FILE);

	# Delete question lines
	while (($#lines > -1) && ($lines[0] =~ /^QS/))
	{
		shift(@lines);
	}

	# Parsing
	my $in = 0;
	my $last = "";
	my @nodes = ();
	my @tree = ();

	foreach my $line (@lines)
	{

		chomp($line);
		if (!($line =~ /^[ ]*$/))
		{
			my @cur = split(/[ ]+/, $line);
			
			if ($in == 1)
			{
				if ($cur[0] eq "}")
				{
					$in = 0;
					push(@tree, generate_tree(0, \@nodes));
					@nodes = ();
				}
				else
				{
					shift(@cur);
					push(@nodes, \@cur);
				}
			}
			else
			{
				if ($cur[0] eq "{")
				{
					$in = 1;
				}
				else
				{
					$last = $line;
				}
			}
		}
	}

	return @tree;
}

############################################################################################################################

my @trees = parse_file($ARGV[0]);
my $i = 2;
foreach my $tree (@trees)
{
	print_tree($tree, "$ARGV[1]/$i.dot");
	my $cmd = "iconv -f ISO-8859-1 -t UTF-8 $ARGV[1]/$i.dot> $ARGV[1]/tmp; mv  $ARGV[1]/tmp $ARGV[1]/$i.dot";
	system($cmd) && die("$0: Echec execution <$cmd>. $!");
	$cmd = "dot -Tsvg $ARGV[1]/$i.dot > $ARGV[1]/$i.svg";
	system($cmd) && die("$0: Echec execution <$cmd>. $!");
	$i = $i +1;
}

