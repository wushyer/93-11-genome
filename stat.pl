open IN,"$ARGV[0]" or die $!;
while(<IN>){
	chomp;
	@F=split;
	next unless $F[2]>1 || $F[4] >1;

	if ($F[2] ==$F[4]){
		print "$_\tTP1\n" if $F[5]!~/,/ || $F[6]!~/,/;
		print "$_\tTP2\n" if $F[5]=~/,/ && $F[6]=~/,/;
	}elsif($F[2]==1  && $F[4] >1){
		print "$_\tTP3\n" if $F[5]!~/,/ || $F[6]!~/,/;
		print "$_\tTP4\n" if $F[5]=~/,/ && $F[6]=~/,/;
	}elsif($F[2]>1  && $F[4] ==1){
		print "$_\tTP5\n" if $F[5]!~/,/ || $F[6]!~/,/;
		print "$_\tTP6\n" if $F[5]=~/,/ && $F[6]=~/,/;	
	}else{
		print "$_\tTP7\n" if $F[5]!~/,/ || $F[6]!~/,/;
		print "$_\tTP8\n" if $F[5]=~/,/ && $F[6]=~/,/;	
	}
}
close IN;
