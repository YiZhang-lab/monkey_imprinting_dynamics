#!/usr/bin/perl


($file1,$cutoff,$totalcount,$baseline)=@ARGV;
if((not defined $file1)||(not defined $cutoff)||(not defined $totalcount)||(not defined $baseline)) {
        die "./Usage <dif_mCG.txt> mCG_dif_cutoff min_number_for_DMR baseline_for_low_mCG"
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
@pat_value=();
@mat_value=();
while(defined($perIns = <FILE1>)){

     
     chomp($perIns);
     $perIns1=$perIns;
     @arr1=split(/\t/,$perIns);
     $key1[$i]=$arr1[1];
     $key2[$i]=$arr1[0];
     $key[$i]=join("_",$arr1[0],$arr1[1]);
     $value[$i]=$arr1[2];
     $pat_value[$i]=$arr1[3];
     $mat_value[$i]=$arr1[4];
     $i++;
}

close FILE1 or die $!;



for($t=0;$t<$i;$t++){

  $flag=$t;

  if($value[$t]>=$cutoff){
	$count=1;
  }  
  else{
	next;
  }

  $j=$t+1;
 
  while($key2[$j] eq $key2[$t]){

	if (($key1[$j]-$key1[$j-1]) < 500) {
  	
         if(($value[$j]>=$cutoff)){
		$count++;
		$j++;
	 }
         else{
		$tmp_value=0;
		$judge=0;
		for ($k=$j;$k<$j+10;$k++){
			if (($key2[$k] eq $key2[$t]) && ($key1[$k]-$key1[$j] < 5000)) {
				$tmp_value=$tmp_value+$value[$k];
				$judge=1;
		  	}
			else {
				$judge=0;
				last;
				}
		}
		$ave_tmp_value=$tmp_value/10;
		if (($ave_tmp_value >= $cutoff) && $judge) {
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

  $methC=0;$meth=0;$pat_tot=0;$mat_tot=0;
  
  if($count>=$totalcount){
     
     while($t<$j){
          # print "$h_GpC{$key[$t]}\n";
          
          $meth=$meth+$value[$t];
	  $pat_tot=$pat_tot+$pat_value[$t];
	  $mat_tot=$mat_tot+$mat_value[$t];
          $methC++;
          $t++;
     }
     
   $meth_ave=$meth/$methC;
   $pat_ave=$pat_tot/$methC;
   $mat_ave=$mat_tot/$methC;
   $end=$key1[$t-1];
	if($pat_ave <= $baseline) {
		
   		printf "%s\t%d\t%d\t%.3f\t%.3f\n",$key2[$t],$key1[$flag],$end,$pat_ave,$mat_ave;
	}
  }
  

}
