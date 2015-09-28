#!/bin/perl

my @list_keys = split(/;/, $ARGV[0]);
my $format = $ARGV[1];
my %hash_info = ();

# Fill the first !
my %tmp = ();
# print($#ARGV + "\n");
open(FILE, sprintf($format, $ARGV[2])) or die("cannot open " + sprintf($format, $ARGV[2])+ ": $!");
while(<FILE>) {
    my $line = $_;
    chomp($line);
    
    # Fill a tmp hash
    my @elts = split(/;/, $line);
    @{$hash_info{$elts[0]}} = ($elts[1]);
}
close(FILE);

# Fill the nexts
for (my $i=3; $i<=$#ARGV; $i++) {
    open(FILE, sprintf($format, $ARGV[$i])) or die("cannot open " + sprintf($format, $ARGV[$i])+ ": $!");
    while(<FILE>) {
        my $line = $_;
        chomp($line);
        
        # Fill a tmp hash
        my @elts = split(/;/, $line);
        push(@{$hash_info{$elts[0]}}, $elts[1]);
    }
    close(FILE);
}

print("#categories;" . join(";", @ARGV[2..$#ARGV]) . "\n");
for my $k (@list_keys) {
    print("$k;" . join(";", @{$hash_info{$k}}) . "\n");
}
