open IN, "$ARGV[0]" or die $!;
while(<IN>){
	chomp;
	@F=split;
	$pos{$F[1]}{"$F[2],$F[3]"}=$_;
}
close IN;


open PA,"$ARGV[1]" or die $!;
while(<PA>){
	chomp;
	@F=split;
	for $se(keys %{$pos{$F[1]}}){
		($s,$e)=split/,/,$se;
		next if $s==$F[2] && $e==$F[3];
		next if $s >$F[3];
		next if $e < $F[2];
		#print STDERR "$F[0]\t$F[1]\t$F[2]\t$F[3]\t$se\t$s\t$e\n";
		print "$_\t$pos{$F[1]}{$se}\n";
	}
}
close PA;
