my $usage = <<__USAGE__;
	Usage :
	     perl get_id.pl A.id B.id N > O.id
		 N num 
		   1-> output shared-id (default)
		   2-> output A id whithout B
		   3-> output B id whithout A
__USAGE__
;
if (@ARGV<2) {
	die $usage;
}

my $num=1;
$num=$ARGV[2] if (@ARGV>=3);

open IN1,"$ARGV[0]" or die $!;
my %idA;
while (<IN1>){
chomp;
s/\r//;
$idA{$_}++;
}
close IN1;

open IN2,"$ARGV[1]" or die $!;
my %idB;
while (<IN2>){
chomp;
s/\r//;
$idB{$_}++;
}
close IN2;

my $out;
if ($num==1) {
	$out=share(\%idA,\%idB);
}
if ($num==2) {
	$out=noshare(\%idA,\%idB);
}
if ($num==3) {
	$out=noshare(\%idB,\%idA);
}
for my $tid(keys %$out) {
	print "$tid\n";
}
sub share{
	my $id1=shift;
	my $id2=shift;
	for my $id(keys %$id1) {
		if ($id2->{$id}) {
			$id{$id}++;
		}
	}
	return \%id;
}
sub noshare{
	my $id1=shift;
	my $id2=shift;
	for my $id(keys %$id1) {
		if ($id2->{$id}) {
			next;
		}else{
			$id{$id}++;
		}
	}
	return \%id;
}