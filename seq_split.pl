#!/usr/bin/perl

$usage=<<_USAGE_;

$0 fasta parts

e.g. $0 input.fa 4		split input.fa into 4 parts

_USAGE_

if (@ARGV < 2) {print $usage; die;}
	
my $fasta=shift @ARGV;
my $parts=shift @ARGV;

for $n(1..$parts){
	open $n,">","$fasta.split.$n" || die;
}

open FASTA,"<",$fasta || die;
while(<FASTA>){
	if (/^>/){
		$n=int(rand($parts))+1;
	}
	print $n $_;
}

for $n(1..$parts){
	close OUT;
}
close FASTA;