use strict;
use Bio::Seq;
use Bio::SeqIO;
use threads;
use threads::shared;
use Thread::Queue;
use File::Basename;

my $Time_Start =scalar (localtime(time()));
print "************...Job[$Time_Start]...************\n";

if (-e "star") {
	next;
}else{
	open STAR,">star";
	print STAR "**********\n";
	close STAR;
}

#my $clustalo =  "/share/disk6/wangsen/software/clustal-omega-1.2.1/clustalo-1.2.0-Ubuntu-32-bit";
my $clustalo = $ARGV[4];
my $trimal = $ARGV[5];
my $tread = $ARGV[3];
my %Proseqs;
my $Proseqs = Bio::SeqIO->new(-file => "$ARGV[1]",-format => "fasta");
while (my $sequence = $Proseqs->next_seq()) {
	my $id = $sequence->id();
	my $seq = $sequence->seq();
	$Proseqs{$id} = $seq;
}

my %CDSseqs;
my $CDSseqs = Bio::SeqIO->new(-file => "$ARGV[2]",-format => "fasta");
while (my $sequence = $CDSseqs->next_seq()) {
	my $id = $sequence->id();
	my $seq = $sequence->seq();
	$CDSseqs{$id} = $seq;
}

my $Time_In =scalar (localtime(time()));
print "************...Job[$Time_In]...************\n";

open PAIR,"$ARGV[0]" or die $!;
while (<PAIR>){
	chomp;
	next if ($_ eq '' || /^\s+$/);
	my $line=$_;
	Processor($line);
}

my $Time_End =scalar (localtime(time()));
print "************...Job[$Time_End]...************\n";

sub Processor{
	my $pairs = shift @_;
	open TMP,">tmp.out" or die $!;
	for my $sp(sort (split/\s+/,$pairs)){
		print TMP ">$sp\n$Proseqs{$sp}\n";
	}
	close TMP;
	ALN("tmp.out","tmp.aln");
	system("cat tmp.out star >> all.out");
	my $Aln_CDSseqs = Prot2CDS("tmp.aln");
	system("cat tmp.aln star >> all.aln");
	open OUTTMP, ">tmp.cds.aln" or die $!;
	for my $id(sort keys %$Aln_CDSseqs){
		my $sp = (split /\|/,$id)[0];
		print OUTTMP ">$id\n$Aln_CDSseqs->{$id}\n";
	}
	close OUTTMP;
	system("cat tmp.cds.aln star >> all.cds.aln");
	my $cmd = "$trimal -in tmp.cds.aln -out tmp.phy -phylip_paml -nogaps 2>trimal.error ";
	system("$cmd");
	system("cat tmp.phy star >> all.nogap.phy") if (-e "tmp.phy");
	system("rm tmp*");
}


sub ALN{
	my $file = shift;
	my $out = shift;
	my $cmd = "$clustalo -i $file -o $out --threads=$tread >aln.log 2> aln.error ";
	system($cmd);
}

sub Prot2CDS{
	my $aln_file = shift;
	my $Aln_Proseqs = Bio::SeqIO->new(-file => $aln_file,-format => 'fasta');
	my %Aln_Proseqs;
	while (my $sequence = $Aln_Proseqs->next_seq()) {
		my $id = $sequence->id();
		my $seq = $sequence->seq();
		$Aln_Proseqs{$id} = $seq;
	}
	my %Aln_CDSseqs;
	for my $id(sort keys %Aln_Proseqs) {
		if ($CDSseqs{$id}) {
			my @AAs=split//,$Aln_Proseqs{$id};
			my $seqNew="";my $n=0;
			for my $i (0..$#AAs) {
				if ($AAs[$i] ne '-') {
					$n++;
					my $code = substr($CDSseqs{$id},($n-1)*3,3);
					my $aa = code2aa($code);
					if ($aa eq $AAs[$i]) {
						#print STDERR "($aa)\tOK!\n";
					}else{
						print STDERR "$id:$AAs[$i]\t$aa\tNO!\n";
					}
					print STDERR "$id:$AAs[$i]\t$aa\tNO-Star!\n" if $aa eq "*";
					$code = "---" if $aa eq "*";
					$seqNew .= $code;
				}else{
					 $seqNew .= "---";
				}
			}
			$Aln_CDSseqs{$id} = $seqNew;
		}else{
			print STDERR "NO $id sequence\n";
		}
	}
	return \%Aln_CDSseqs;
}

sub code2aa{
	my $code = shift;
	my $seqcode = Bio::Seq->new(-display_id => 'id',-seq => $code);
	my $aa = $seqcode->translate(-codontable_id =>1,)->seq();
	return $aa;
}

