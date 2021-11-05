
use Getopt::Long;
use File::Basename qw<basename dirname>;

my $version="V1.00";

my $usage = <<__USAGE__;

################# EUSAGE ##############################
Usage :
	merge_files.pl  -r ref file -n col of the ref -i file1 [-i file2...] -c col of the file1[-c n2 -c n3...] -o out file

	-r --ref         Specify the ref file
	-n               the col of the ref file used to merge the file               
	-i --seq         Specify the input file
	-d --dir         Specify the input dir
	-c               the col of the input file used to merge the files
	-o --out         Specify the output file
	-s --sep         Specify the field separator:Tab[default] or BS(blank space)
	-p --cpu         cpu[1]
	-v --version
	-h --help

Contact : Wang Sen <wangsen\@big.ac.cn>
#################################################################

__USAGE__
;

## Input parameters
my @filelist;
my @cols;
my $reffile;
my $dir;
my $n;
my $output;
my $sep="Tab";
my $cpu=1;
my $help;
&GetOptions ( "i=s"        => \@filelist,
              "d=s"        => \$dir,
              "c=s"        => \@cols,
              "ref|r=s"    => \$reffile,
              "n=s"        => \$n,
              "s=s"        => \$sep,
              "out|o=s"    => \$output,
              "version|v"  => \$version,
              "help|h"     => \$help,
             );

unless ($reffile ) {
	die $usage;
}
if ($help) { 
	die $usage;
}
$|=1;
my $Time_Start =scalar (localtime(time()));
print "************...Job[$Time_Start]...************\n";
my @ids;my %hash;
open REF,"$reffile" or die $!;
while (<REF>) {
	chomp;s/\r//;
	my @array;
	@array=split if $sep=~/BS/i;    
	@array=split/\t/,$_ if $sep=~/Tab/i;
	if ($n-1 <= $#array){
		push @ids,$array[$n-1];
		$hash{$array[$n-1]}=$_;
	}
}
close REF;

my %new;my %count;
if ($filelist[0]){
	for my $i(0..$#filelist) {
		#print "$filelist[$i]\n";
		open IN,"$filelist[$i]" or die $!;
		while (<IN>) {
			chomp;s/\r//;
			next if ($_ eq '' || /^\s+$/);
			my @array;
			@array=split if $sep=~/BS/i; 
			@array=split/\t/,$_ if $sep=~/Tab/i;
			my $l=$cols[$i]-1;
			$new{$array[$l]}{$filelist[$i]}=$_ if $hash{$array[$l]};
			#my $c=$_;$c=~s/\S+/-/g;
			$count{$filelist[$i]}="-". ("\t-" x $#array);
		}
		close IN;
	}
}

if ($dir){
	opendir DIR,"$dir" or die $!;
	for my $file(readdir DIR) {
		next unless ($file=~/^\w+/);
		push @filelist, $file;
		open IN,"$dir/$file" or die $!;
		#print "$dir/$file\n";
		while (<IN>) {
			chomp;s/\r//;
			next if ($_ eq '' || /^\s+$/);
			my @array;
			@array=split if $sep=~/BS/i; 
			@array=split/\t/,$_ if $sep=~/Tab/i;
			my $l=$cols[-1]-1;
			$new{$array[$l]}{$file}=$_ if $hash{$array[$l]};
			#my $c=$_;$c=~s/\S+/-/g;
			$count{$file}="-". ("\t-" x $#array);
		}
		close IN;
	}
	closedir DIR;
}
my $filelist=join",",@filelist;
print "$filelist\n";
open OUT,">$output" or die $!;
open REF,"$reffile" or die $!;
while (<REF>) {
        chomp;s/\r//;
	next if ($_ eq '' || /^\s+$/);
        my @array;
        @array=split if $sep=~/BS/i;
        @array=split/\t/,$_ if $sep=~/Tab/i;
	print OUT "$_";
	for my $i(0..$#filelist) {
		if($new{$array[$n-1]}{$filelist[$i]}){
			print OUT "\t$new{$array[$n-1]}{$filelist[$i]}";
		}else{
			print OUT "\t$count{$filelist[$i]}";
		}
	}
	print OUT "\n";
}
close REF;
close OUT;
my $Time_End =scalar (localtime(time()));
print "************...Job[$Time_End]Done...************\n";
