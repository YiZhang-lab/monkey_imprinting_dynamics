#!/usr/bin/perl

my ($file,$number) = @ARGV;

if((not defined $file) || (not defined $number)) {
	die "./usage sam_file(mapped by Bismark) minimal_CG_per_read";
}

open(FILE, $file) or die $!;

$cutoff = $number;

while (my $line = <FILE>) {
	chomp $line;
	@group = split(/\t/, $line);
	$chr = $group[2];
	$start = $group[3];
	$end = $start + 50;
	$CG_line = $group[15];
	$CG_line =~ m/XM:Z:(.+)/;
	$mCG_state = $1;
	if ($mCG_state =~ /[zZ]/) {
	
	}
	else {
		next;
	}
	@CG = split(//,$mCG_state);
	$umCG = 0;
	$mCG = 0;

	for($j=0; $j<@CG; $j++) {
		if ($CG[$j] eq "z") {
			$umCG++;
		}
		elsif ($CG[$j] eq "Z") {
			$mCG++;
		}
		else {
			next;
		}
	}
	
	if (($mCG + $umCG) >= $cutoff) {
		printf "%s\t%d\t%d\t%.2f\n",$chr, $start, $end, $mCG/($mCG + $umCG);
	}
	else {
		next;
	}
}

close FILE or die $!;
