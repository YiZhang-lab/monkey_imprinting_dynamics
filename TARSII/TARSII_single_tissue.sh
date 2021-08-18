#!/bin/bash

echo "

	please indicate the path of the program folder in below when use for the first time


"

EXPECTED_ARGS=9

if [ $# -ne $EXPECTED_ARGS ];
then
	echo "
	Usage: ./bash File.txt(mCG_level_base_resolution) sam_file(deduplicated) minimal_CG_number_in_PMD minimal_mCG_level_in_PMD maximal_mCG_level_in_PMD minimal_CG_number_per_read mini_read_num_per_DMR bin_number_in_DMR imp_identify_cutoff(recommend 0.3)
	
	"


exit
fi

path= pwd
CG_file=$1
bam_file=$2
DMR_CG=$3
DMR_min=$4
DMR_max=$5
ICR_CG=$6
ICR_read=$7
ICR_bin=$8
imp_cutoff=$9

echo "" >> log.txt
echo "chosen $DMR_CG number as DMR cutoff, minimal mCG level is $DMR_min, maximal mCG level is $DMR_max. For ICR identify, $ICR_CG CG should be contained in a single read, at least $ICR_read reads should contained in one DMR, using $ICR_bin number of bins to calculation. Imprinting cutoff is $imp_cutoff" >> log.txt

file_name=${CG_file##*/}
input=${file_name%.txt}

DMR_identify_extend=$path/find_PMD_in_genome.pl

identify_imp_status=$path/identify_imprinting_status_final.pl
cal_imp_level=$path/cal_imprinting_levels.pl

$DMR_identify_extend $CG_file $DMR_min $DMR_max $DMR_CG > $input\_PMD_extend.bed

$identify_imp_status $input\_PMD_extend.bed $bam_file > $input\_PMD_extend_status.txt


$cal_imp_level $input\_PMD_extend_status.txt $ICR_CG $ICR_read $ICR_bin > $input\_PMD_extend_allelic_perc.txt

awk '{if(($2 >= '$imp_cutoff') && ($3 >= '$imp_cutoff')) print$0}' $input\_PMD_extend_allelic_perc.txt > $input\_candidate.txt

cut -f1 $input\_ICR_extend.txt | sed 's/_/\t/g' - > $input\_candidate.bed
