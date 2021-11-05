use strict;

my $gfffile=$ARGV[0];
my $trgff =$ARGV[1];
my $id=$ARGV[2];
my $updategff=$ARGV[3];
open IN,"$id";
my %trids;
while(<IN>){
	chomp;
	my @F=split;
	my $gene=$1 if $F[1]=~/^(\w+)\./;
	next unless $F[0]=~/TU/i;
	$trids{$F[0]}->{Tr}=$F[1];
	$trids{$F[0]}->{Ge}=$gene;
}
close IN;

open TG,"$trgff";
my %infs;
while(<TG>){
	chomp;
	my @F=split;
	$F[1]=~s/transdecoder/GenePre/;
	if($F[2] eq "mRNA"){
		my $tid=$1 if /ID=([^;\s]+)/;
		my $Tid=$trids{$tid}->{Tr};
		my $Gid=$trids{$tid}->{Ge};
		my $inf=(join "\t",@F[0..7])."\tID=$Tid;Parent=$Gid;";
		push @{$infs{$Tid}},$inf;
	}elsif($F[2] eq "exon"){
		my $tid=$1 if /Parent=([^;\s]+)/;
		my $Tid=$trids{$tid}->{Tr};
		my $Gid=$trids{$tid}->{Ge};
		my $inf=(join "\t",@F[0..7])."\tID=$Tid.exon;Parent=$Tid;";
		push @{$infs{$Tid}},$inf;
	}elsif($F[2] eq "CDS"){
		my $tid=$1 if /Parent=([^;\s]+)/;
		my $Tid=$trids{$tid}->{Tr};
		my $Gid=$trids{$tid}->{Ge};
		my $inf=(join "\t",@F[0..7])."\tID=$Tid.cds;Parent=$Tid;";
		push @{$infs{$Tid}},$inf;
	}elsif($F[2] =~/prime_UTR/){
		my $tid=$1 if /Parent=([^;\s]+)/;
		my $Tid=$trids{$tid}->{Tr};
		my $Gid=$trids{$tid}->{Ge};
		my $inf=(join "\t",@F[0..7])."\tID=$Tid.utr;Parent=$Tid;";
		push @{$infs{$Tid}},$inf;		
	}
}
close TG;

open UTR,"$updategff";
my %update;
while(<UTR>){
	chomp;
	my @F=split;
	$F[1]=~s/\./GenePre/;
	if($F[2] eq "mRNA"){
		my $Tid=$1 if /ID=([^;\s]+)/;
		my $Gid=$1 if /Parent=([^;\s]+)/;
		my $inf=(join "\t",@F[0..7])."\tID=$Tid;Parent=$Gid;";
		push @{$infs{$Tid}},$inf;
	}elsif($F[2] eq "exon"){
		my $Tid=$1 if /Parent=([^;\s]+)/;
		my $inf=(join "\t",@F[0..7])."\tID=$Tid.exon;Parent=$Tid;";
		push @{$infs{$Tid}},$inf;
	}elsif($F[2] eq "CDS"){
		my $Tid=$1 if /Parent=([^;\s]+)/;
		my $inf=(join "\t",@F[0..7])."\tID=$Tid.cds;Parent=$Tid;";
		push @{$infs{$Tid}},$inf;
	}elsif($F[2] =~/prime_UTR/){
		my $Tid=$1 if /Parent=([^;\s]+)/;
		my $inf=(join "\t",@F[0..7])."\tID=$Tid.utr;Parent=$Tid;";
		push @{$infs{$Tid}},$inf;
	}
}
close UTR;

open GFF,"$gfffile";
while(<GFF>){
	chomp;
	my @F=split;
	next if $F[2] eq "gene";
	my $tid=$1 if /ID=(\w+\.t\d+)/;
	if ($infs{$tid}){
		next if $F[2] ne "mRNA";
		for my $inf(@{$infs{$tid}}){
			print "$inf\n";
		}
	}else{
		print "$_\n";
	}
}
close GFF;
