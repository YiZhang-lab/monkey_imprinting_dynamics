#!/usr/bin/perl
 
my ($file1,$file2,$binnumber)=@ARGV;

if ((not defined $file1) || (not defined $file2) || (not defined $binnumber)) {
 	die "use:./heatmapbyregion_Refseq.pl <file1.regionfile.bed> <mCG.txt> <binnumber>"}

my $chr1; my $start1; my $end1; my $NO; my $peak;
my $chr2; my $start2; my $end2; my $rpkm; my $rpkmt;
my $count=0; my $bound; my $i=0; my $id; my $name; my $side; my @bin;

open (FILE2,$file2) or die $!;

while (my $line2=<FILE2>) {
	chomp ($line2);
	($chr2,$start2,$rpkm)=split(/\s+/,$line2);

	if (($pre_chr ne $chr2) && $pre_chr) {
		$i=0;
	}
	$chrmid=$start2;
	$$chr2[$i]=$chrmid;
	$pre_chr=$chr2;
	$i++;
	$bound->{$chr2}->{$chrmid}=$rpkm;
}

close  FILE2 or die $!;

open (FILE1,$file1) or die $!;

while (my $line=<FILE1>) {
	chomp($line);
	($chr1,$start1,$end1)=split(/\s+/,$line);
	$count=0;
	$rpkmt=0;
	$i=0;
	$j=0;
	$binsize=int (($end1-$start1)/$binnumber);
	$binfactor=($end1-$start1)/1000;
	$print="$chr1"."_"."$start1"."_"."$end1\t";
	@bin=();

	for($k=0;$k<$binnumber;$k++){
		$end1=$start1+$binsize;
		$count=0;

		for($i=$j;$i<=$#$chr1;$i++) { 
	       		next if ($$chr1[$i]<=$start1);
			if ($$chr1[$i]>$end1) {
				$j=$i;
				last;
			}
		$rpkmt=$rpkmt+($bound->{$chr1}->{$$chr1[$i]});
		$count++;
		}

		if ($count!=0) {
			$bin[$k]=$rpkmt/$count;
			$bin[$k]=(int ($bin[$k]*100))/100;
			$print=$print."$bin[$k]\t";                                        
		}
         	else {
			$bin[$k]="NA";
			$print=$print."$bin[$k]\t";
		}

		$count=0; 
		$rpkmt=0;
		$start1=$start1+$binsize;
	}

	$print=~s/\t$//;
	print "$print\n";
}

close FILE1 or die $!;
