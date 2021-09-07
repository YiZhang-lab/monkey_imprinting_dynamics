#!/usr/bin/perl
my ($file)=@ARGV;
if (not defined $file) {
die "use:./usage bed_file"}
open (FILE,$file) or die $!;

while (my $line=<FILE>) {
	chomp $line;
	@group=split(/\s+/,$line);
	$chr=$group[0];
	$start=$group[1];
	$end=$group[2];
	
	if (($pre_chr ne $chr) && $pre_chr) {
		printf "%s\t%d\t%d\n",$pre_chr,$print_start,$print_end;
		$print_start=$start;
		$print_end=$end;
		$pre_chr=$chr;
                $pre_start=$start;
                $pre_end=$end;
	}
	
	elsif (($start > $pre_end) && $pre_chr) {
		printf "%s\t%d\t%d\n",$pre_chr,$print_start,$print_end;
		$print_start=$start;
		$print_end=$end;
		$pre_chr=$chr;
                $pre_start=$start;
                $pre_end=$end;
	}

	elsif (($end < $pre_end) && $pre_chr) {
		$pre_chr=$chr;
	}
	elsif(($end >= $pre_end) && $pre_chr) {
		$print_end=$end;
		$pre_chr=$chr;
		$pre_end=$end;
	}
	else {
		$print_start=$start;
		$print_end=$end;
		$pre_chr=$chr;
                $pre_start=$start;
                $pre_end=$end;
	}
}

printf "%s\t%d\t%d\n",$pre_chr,$print_start,$pre_end;
 
close FILE or die $!;
