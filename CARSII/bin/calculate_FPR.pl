#!/usr/bin/perl

($file1, $file2, $hypo_read, $hyper_read, $hypo_p, $hyper_p, $times) = @ARGV;

if((not defined $file1) || (not defined $file2) || (not defined $hypo_read) || (not defined $hyper_read) || (not defined $hypo_p) || (not defined $hyper_p) || (not defined $times)) {
	die "./Usage candidate_DMC_with_reads_number reads_mCG_file hypo_read_cutoff hyper_read_cutoff hypo_read_percentage hyper_read_percentage test_times";
}

open (FILE2, $file2) or die $!;

$j=0;
@value=();
while (my $line = <FILE2>) {
	chomp $line;
	@group = split(/\s+/, $line);
	$value[$j]=$group[3];
	$j++;
}

close FILE2 or die $!;


open (FILE1, $file1) or die $!;

while (my $line = <FILE1>) {
	chomp $line;
	@group = split(/\t/,$line);
	$read_num = $group[1];
	$flag=0;

	for($i=0; $i<$times; $i++) {

		$hyper = 0;
		$hypo = 0;

		for ($k=0; $k<$read_num; $k++) {
			$random_k = int(rand($j));
			$random_mCG = $value[$random_k];

			if ($random_mCG >= $hyper_read) {
				$hyper++
			}
			elsif ($random_mCG <= $hypo_read) {
				$hypo++
			}
			else {
				next;
			}
		}

		if (($hyper/$read_num >= $hyper_p) and ($hypo/$read_num >= $hypo_p)) {
			$flag++;
		}

	}

	$FDR = $flag/$times;

	printf "$group[0]\t$FDR\n"
}

close FILE1 or die $!;
