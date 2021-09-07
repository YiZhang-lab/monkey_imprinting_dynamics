#!/usr/bin/perl

my ($file, $base_num, $read_num, $total_bin) = @ARGV;

if((not defined $file) | (not defined $base_num) | (not defined $read_num) | ($total_bin <= 0)) {
	die "
	./usage file minimal_base_number_per_reads minimal_read_number_per_region bin_number_from_0_to_1_perc \n";
}

open(FILE, $file) or die $!;

while(my $line = <FILE>) {
	chomp $line;
	($chr, $state)=split(/\t/, $line);
	@group=split(/-/, $state);
	$start = $group[0];
	$end = $group[1];
	$readcounts = 0;
	$totalreads = 0;
	@totalperc=();
	@bin_count=();
	for($i=2; $i<@group; $i++) {
		($perc, $basenumber) = split(/_/, $group[$i]);
		if($basenumber >= $base_num) {
			push @totalperc, $perc;
			$totalreads++;
		}
		else {
			next;
		}
	}
	if(@totalperc >= $read_num) {
		$step = 1/$total_bin;
		for($k=0;$k<$total_bin;$k++) {
			$bin_count[$k] = 0;
		}
		for($j=0;$j<@totalperc;$j++) {
			$count = int($totalperc[$j]/$step);
			if($count == $total_bin) {
				$bin_count[$total_bin-1]++;
			}
			else {
				$bin_count[$count]++;
			}
		}
		$position = $chr."_".$start."_".$end."\t".sprintf("%.2f",($bin_count[0]/$totalreads))."\t".sprintf("%.2f",($bin_count[$total_bin-1]/$totalreads));
		for($r=0;$r<@bin_count;$r++) {
			$position = $position."\t".$bin_count[$r];
		}
		print "$position\n";
	}
	else {
		next;
	}
}

close FILE or die $!;
