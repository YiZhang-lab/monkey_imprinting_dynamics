#!/usr/bin/perl


($file1,$cutoff1,$cutoff2,$totalcount)=@ARGV;
if((not defined $file1) || (not defined $cutoff1) ||( not defined $cutoff2) || (not defined $totalcount)) {
        die "./Usage file(mCG txt file) mini_value_cutoff max_value_cutoff min_number_for_DMR"
}
# filw chr pos_start pos_end p_value others

open (FILE1,$file1) or die $!;

$i=0;
$tot_value=0;
@arr1=();
@key=();
@key1=();
@key2=();
@value=();
while(defined($perIns = <FILE1>)){

     
     chomp($perIns);
     $perIns1=$perIns;
     @arr1=split(/\t/,$perIns);
     $key1[$i]=$arr1[1];
     $key2[$i]=$arr1[0];
     $key[$i]=join("_",$arr1[0],$arr1[1]);
     $value[$i]=$arr1[2];
     $i++;
}

close FILE1 or die $!;



for($t=0;$t<$i;$t++){

  $flag=$t;

  if(($value[$t] >= $cutoff1) && ($value[$t] <= $cutoff2)) {
	$count=1;
  }  
  else{
	next;
  }

  $j=$t+1;
 
  while($key2[$j] eq $key2[$t]){

	if (($key1[$j]-$key1[$j-1]) < 500) {
  	
         if(($value[$j] >= $cutoff1) && ($value[$j] <= $cutoff2)) {
		$count++;
		$j++;
	 }
         else{
		$tmp_value1=0;
		$tmp_value2=0;
		$judge1=0;
		$judge2=0;
		for ($f=$j-5;$f<$j;$f++) {
			if (($key2[$f] eq $key2[$t]) && ($key1[$j]-$key1[$f] < 2500)) {
				$tmp_value1 = $tmp_value1 + $value[$f];
				$judge1=1;
			}
			else {
				$judge1=0;
				last;
			}
		}

		for ($k=$j;$k<$j+5;$k++){
			if (($key2[$k] eq $key2[$t]) && ($key1[$k]-$key1[$j] < 2500)) {
				$tmp_value2=$tmp_value2+$value[$k];
				$judge2=1;
		  	}
			else {
				$judge2=0;
				last;
				}
		}
		$ave_tmp_value1=$tmp_value1/5;
		$ave_tmp_value2=$tmp_value2/5;
		if ((($ave_tmp_value1 >= $cutoff1) && ($ave_tmp_value1 <= $cutoff2)) || (($ave_tmp_value2 >= $cutoff1) && ($ave_tmp_value2 <= $cutoff2)) && ($judge1 || $judge2)) {
		$count++;
		$j++;
		}
		else {
			last;
		}
	}
	}
	else {
		last;
	}
     
  } 

  $methC=0;$meth=0;
  
  if($count>=$totalcount){
     
     while($t<$j){
          # print "$h_GpC{$key[$t]}\n";
          
          $meth=$meth+$value[$t];
          $methC++;
          $t++;
     }
     
   $meth_ave=$meth/$methC;
   $end=$key1[$t-1];
   printf "%s\t%d\t%d\t%.3f\n",$key2[$flag],$key1[$flag],$end,$meth_ave;
  }
  

}

#close FILE1 or die $!;
