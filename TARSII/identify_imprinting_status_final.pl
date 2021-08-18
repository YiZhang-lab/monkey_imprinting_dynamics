#!/usr/bin/perl

my ($file1,$file2)=@ARGV;

if((not defined $file1) || (not defined $file2)) {
	die "./usage ICR_region.bed sam_file_from_Bismark_deduplicated_by_JAVA" or $!;
}

open(FILE1, $file1) or die $!;

$pre_chr = "";
$t = 0;
$x = 0;
@big_chr=();
while (my $line=<FILE1>) {
	chomp $line;
	@group = split(/\s+/, $line);
	$chr = $group[0];
	$start = $group[1];
	$end = $group[2];
	$ID = $start."-".$end;
	if ($pre_chr ne $chr) {
		$t = 0;
		$big_chr[$x] = $chr;
		$$chr[$t] = $ID;
		$pre_chr = $chr;
		$t++;
		$x++;
	}
	else {
		$$chr[$t] = $ID;
		$pre_chr = $chr;
		$t++;
	}
}

close FILE1 or die $!;

open(FILE2, $file2) or die $!;


$pre_chr = "";
while (my $line=<FILE2>) {
	chomp $line;
	@group = split(/\t/, $line);
	$chr = $group[2];
	$start = $group[3];
	$cigar = $group[5];
	$group13 = $group[15];
	$group13 =~ m/XM:Z:(.+)/;
	$mCG_state = $1;
	if ($mCG_state =~ /[zZ]/) {
	}
	else {
		next;
	}
	$read_lenth = 0;
	$ref_pos = $start-1;
	$flag = 1;
	if($pre_chr ne $chr) {
		$f = 0;
		$pre_chr = $chr;
	}
	else {
		$pre_chr = $chr;
	}
	
	while($cigar =~ /([0-9]+)/g) {
		$num_base = $1;
		if($cigar =~ /\G([MID])/) {
			$type = $1;
			if($type eq "M") {
				$read_lenth = $read_lenth + $num_base;
				$ref_pos = $ref_pos + $num_base;
			}
			elsif($type eq "D") {
				$ref_pos = $ref_pos + $num_base;
			}
			elsif($type eq "I") {
				$read_lenth = $read_lenth + $num_base;
			}
			else {
				$flag = 0;
				last;
			}
		}
	}


	if ($flag) {
			$tag = 0;
			for($i = $f; $i < @$chr; $i++) {
			($ICR_start, $ICR_end) = split(/-/,$$chr[$i]);
			if($ICR_end <= $start) {
				next;
			}
			elsif($ICR_start >= $ref_pos) {
				$f = $i;
				last;
			}
			elsif(($start >= $ICR_start) & ($ref_pos <= $ICR_end )) {
				$tag = 1;
				$count_start = 0;
				$count_end = $read_lenth;
				$f = $i;
				last;
			}
			elsif($start < $ICR_start) {
				$tag = 1;
				$tmp_lenth = 0;
				$tmp_pos = $start-1;
				while($cigar =~ /([0-9]+)/g) {
	               			$num_base = $1;
	 	      			if($cigar =~ /\G([MID])/) {
		               			$type = $1;
	                			if($type eq "M") {
		                       			$tmp_lenth = $tmp_lenth + $num_base;
							$tmp_pos = $tmp_pos + $num_base;
		                       			if ($tmp_pos >= $ICR_start) {
								$dif_lenth = $tmp_pos - $ICR_start;
								$count_start = $tmp_lenth - $dif_lenth - 1;
								$count_end = $read_lenth;
								last;
							}
							else {
								next;
							}
	               				}
		               			elsif($type eq "D") {
		                       			$tmp_pos = $tmp_pos + $num_base;
							if($tmp_pos >= $ICR_start) {
								$count_start = $tmp_lenth;
								$count_end = $read_lenth;
								last;
							}
							else {
								next;
							}
	              				 }
		               			elsif($type eq "I") {
		                       			$tmp_lenth = $tmp_lenth + $num_base;
		               			}
					}
				}	
				$f = $i;
				last;
			}
			elsif($ref_pos > $ICR_end) {
				$tag = 1;
				$tmp_lenth = 0;
				$tmp_pos = $start -1;
				while($cigar =~ /([0-9]+)/g) {
					$num_base = $1;
					if($cigar =~ /\G([MID])/) {
						$type = $1;
						if($type eq "M") {
							$tmp_lenth = $tmp_lenth + $num_base;
							$tmp_pos = $tmp_pos + $num_base;
							if($tmp_pos >= $ICR_end) {
								$dif_lenth = $tmp_pos - $ICR_end;
								$count_start = 0;
								$count_end = $tmp_lenth - $dif_lenth;
								last;
							}	
							else {
								next;
							}
						}
						elsif($type eq "D") {
							$tmp_pos = $tmp_pos + $num_base;
							if($tmp_pos >= $ICR_end) {
								$count_start = 0;
								$count_end = $tmp_lenth;
								last;
							}
						}
							elsif($type eq "I") {
								$tmp_lenth = $tmp_lenth + $num_base;
						}
					}
				}
				$f = $i;
				last;
			}
			else {
				$f = $i;
				last; #the situation where reads contain ICR domain is not considered
			}
		}
		if($tag) {
			@CG = split(//,$mCG_state);
			$tmp_CG = 0;
			$tmp_mCG = 0;
			$tmp_perc = "";
			for($j = $count_start; $j < $count_end; $j++) {
				if($CG[$j] eq "z") {
					$tmp_CG = $tmp_CG + 1;
				}
				elsif($CG[$j] eq "Z") {
					$tmp_mCG = $tmp_mCG + 1;
				}
				else {
					next;
				}
			}
			if(($tmp_CG + $tmp_mCG) >= 1) {
				$tmp_perc = sprintf("%.2f",$tmp_mCG/($tmp_CG + $tmp_mCG));
				$$chr[$i] = $$chr[$i]."-".$tmp_perc."_".($tmp_CG + $tmp_mCG);
			}
			else {
				next;
			}	
		}
		else {
			next;
		}
	}
	else {
		next;
	}
}

close FILE2 or die $!;

for($b = 0; $b < @big_chr; $b++) {
	$target = $big_chr[$b];
	for($d = 0; $d < @$target; $d++) {
		printf "%s\t%s\n",$target,$$target[$d];
	}
}


