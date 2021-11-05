
$tfile=$ARGV[0];
$pfile=$ARGV[1];
$ifile=$ARGV[2];
open TID,"$tfile" or die $!;
while(<TID>){
	chomp;
	@F=split;
	for $id(split/,/,$F[1]){
		$tids{$id}=$F[0];
	}
}
close TID;

open PID,"$pfile" or die $!;
while(<PID>){
	chomp;
	@F=split;
	for $id(split/,/,$F[1]){
		$pids{$id}=$F[0];
	}
}
close PID;

open IID,"$ifile" or die $!;
while(<IID>){
	chomp;
	@F=split;
	$inft="-";
	%hash=();
	$tn=0;
	if(/TU/){
		@tmp=();
		while(/(TU[^,\s]+)/g){
			push @tmp,$1;
			$id=$tids{$1};
			$hash{$id}=1;
		}
		$inft=join",",@tmp;
		$tn= scalar (keys %hash);
	}
	$infm="-";
	%hash=();
	$pn=0;
	if(/mRNA/){
		@tmp=();
		while(/(mRNA[^,\s]+)/g){
			push @tmp,$1;
			$id=$pids{$1};
			$hash{$id}=1;			
		}
		$infm=join",",@tmp;
		$pn= scalar (keys %hash);
	}
	$infa1="-";
	if(/A1_/){
		@tmp=();
		while(/(A1_[^,\s]+)/g){
			push @tmp,$1;
		}
		$infa1=join",",@tmp;
	}
	$infa2="-";
	if(/A2_/){
		@tmp=();
		while(/(A2_[^,\s]+)/g){
			push @tmp,$1;
		}
		$infa2=join",",@tmp
	}
	print "$F[1]\t$inft\t$tn\t$infm\t$pn\t$infa1\t$infa2\n";
}
close IID;
