#!/usr/bin/perl

if ((not defined $ARGV[0]) || (not defined $ARGV[1]) || (not defined $ARGV[2])) {
die "use:./usage common_bed_file_for_compare minimal_tissue_cover <tissue_files...>"}

$filenumber = $ARGV[1];

open (FILE1,$ARGV[0]) or die $!;

@origin_bed = ();
$i = 0;

while (my $line = <FILE1>) {
	chomp $line;
	($chr, $start, $end) = split(/\s+/,$line);
	$origin_bed[$i][0]=$chr;
	$origin_bed[$i][1]=$start;
	$origin_bed[$i][2]=$end;
	$origin_bed[$i][3]=0;
	$origin_bed[$i][4]=0;
	$i++;	
}

close FILE1 or die $!;

for($j=2;$j<@ARGV;$j++) {

	open (FILE, $ARGV[$j]) or die $!;

	while(my $line = <FILE>) {
		chomp $line;

		($chr, $start, $end) = split(/\s+/, $line);

		for($k=0;$k<@origin_bed;$k++) {
			if($origin_bed[$k][0] ne $chr) {
				next;
			}
			elsif($origin_bed[$k][2] < $start) {
				next;
			}
			elsif($origin_bed[$k][1] > $end) {
				last;
			}
			else {
				$origin_bed[$k][3]++;
				last;
			}
		}
	}

	for($k=0;$k<@origin_bed;$k++) {
		if($origin_bed[$k][3]) {
			$origin_bed[$k][4]++;
			$origin_bed[$k][3]=0;
		}
	}
	
	close FILE or die $!;

}

for($i=0;$i<@origin_bed;$i++) {
	if($origin_bed[$i][4] >= $filenumber) {
		printf "%s\t%d\t%d\n",$origin_bed[$i][0],$origin_bed[$i][1],$origin_bed[$i][2];
	}
}
