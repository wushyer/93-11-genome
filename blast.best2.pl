open BL,"$ARGV[0]" or die $!;
while (<BL>){
        chomp;
        next if $_ eq '' || /^\s+$/;
        my @F=split;
        if ($InfComp{$F[0]}){
                if ($InfComp{$F[0]}->{S} < $F[11]){
                        $InfComp{$F[0]}->{S}=$F[11];
                        $InfComp{$F[0]}->{I}=$_;
                }
        }else{
                $InfComp{$F[0]}->{S}=$F[11];
                $InfComp{$F[0]}->{I}=$_;
        }
}
close BL;

for my $idP(sort keys %InfComp){
        print "$InfComp{$idP}->{I}\t$p\n";
}
