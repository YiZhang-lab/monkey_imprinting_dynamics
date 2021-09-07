#!/usr/bin/perl
($file1,$file2)=@ARGV;
if ((not defined $file1) || (not defined $file2) ) {
	die ("use ./combine_heat <file1> <file2> 'genes in file1 and file2 should be RefSeq id'");
		}
open(FILE2,$file2) or die $!;
	while (my $line=<FILE2>) {
		chomp $line;
		$line=~m/^(.+?)\t(.*)/;
		@line_2=split(/\s+/,$line);
		$line2{$line_2[0]}=$2;
		$name{$line_2[0]}=$line_2[0];
}	
close FILE2 or die $!;
open(FILE1,$file1) or die $!;
	while (my $line=<FILE1>) {
		chomp $line;
		@line_1=split(/\s+/,$line);
		if ($name{$line_1[0]} ne "") {
		$print=$line."\t".$line2{$line_1[0]};
		print "$print\n";
	}
}
close FILE1;
