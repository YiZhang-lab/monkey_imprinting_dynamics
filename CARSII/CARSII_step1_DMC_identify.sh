#!/bin/bash

function Usage() {
	echo "Usage:"
	echo "	CARSII_step1_DMC_identify.sh [essentials]* -g <CpG.bed> -x <mCG.txt> -s <sam> -o <output> [options] -r 3 ..."
	echo ""
	echo ""
	echo "Essential:"
	echo ""
	echo "-g	bed file of CpG islands"
	echo "-x	txt file containing CpG methylation levels in single base resolution"
	echo "  	Note: the txt file contain 3 columns separated by tab: 1.chr; 2.CpG pos; 3.mCG level (0~1)"
        echo ""
	echo "-s	sorted sam file with duplicates removed"
	echo "-o	output file name"
	echo ""
	echo ""
	echo "Optional:"
	echo ""
	echo "-r	mininal CpG number in a single read. Default: 3"
	echo "-l	minimal reads number aligned to each CpG island. Default: 20"
	echo "-b	resolution of reads mCG levels for candidate DMRs, linked to option -c/-C. Default: 5"
        echo "  	Note: -b 5 means to distribute methylated reads into 5 groups for each DMR with reads methylation level range from"
	echo "  	0.0-0.2, 0.2-0.4, 0.4-0.6, 0.6-0.8, 0.8-1.0."
	echo "  	Option -c/-C will difine the reads in first/last bin as hypomethylated/hypermethylated reads"
	echo ""
        echo "-c	cutoff of percentages for hypomethylated reads versus total reads analyzed (<0.5). Default: 0.30 (30%)"
        echo "-C	cutoff of percentages for hypermethylated reads versus total reads analyzed (<0.5). Default: 0.30 (30%)"
	echo "-p	maximal false positive rate allowed for certain imprinted CGI. Default: 0.05"
	echo "-t	test times to calculate false positive rate. Default:10000"
	echo "-d	maximal differences of mCG levels inside the CpG island. Default: 0.2"
	echo ""
}


if [ $# -lt 8 ]
then
	echo ""
	echo "Hello:"
	echo "	Please input the essentail parameters"
	echo ""
	Usage
	exit 1
fi

path=$(cd `dirname $0`; pwd)
ICR_CG=3
ICR_read=20
ICR_bin=5
cutoff_hypo=0.3
cutoff_hyper=0.3
pvalue=0.05
ICR_dif=0.2
test_time=10000

while getopts "g:x:s:o:r:l:b:c:C:p:t:d:" opt
do
	case ${opt} in
		g)
			CGI_file=$OPTARG
			if [ ! -f $CGI_file ]; then
                                echo ""
                                echo "ERROR:"
                                echo "the source file $CGI_file does not exist"
                                echo ""
                                Usage
                                exit 1
                        fi
			;;
		x)
			mCG_file=$OPTARG
			if [ ! -f $mCG_file ]; then
                                echo ""
                                echo "ERROR:"
                                echo "the source file $mCG_file does not exist"
                                echo ""
                                Usage
                                exit 1
                        fi
                        ;;
		s)
			sam_file=$OPTARG
			if [ ! -f $sam_file ]; then
                                echo ""
                                echo "ERROR:"
                                echo "the source file $sam_file does not exist"
                                echo ""
                                Usage
                                exit 1
                        fi
                        ;;
		o)
			input=$OPTARG
			;;
		r)
			ICR_CG=$OPTARG
			;;
		l)
			ICR_read=$OPTARG
			;;
		b)
			ICR_bin=$OPTARG
			;;
		c)
			cutoff_hypo=$OPTARG
			;;
		C)
			cutoff_hyper=$OPTARG
			;;
		p)
			pvalue=$OPTARG
			;;
		t)
			test_time=$OPTARG
			;;
		d)
			ICR_dif=$OPTARG
			;;
		\?)
			echo ""
                        echo "ERROR:"
                        echo "options not recognized"
                        echo ""
                        Usage
                        exit 1
                        ;;
	esac
done

hypo_mCG=`awk 'BEGIN{printf "%.2f", 1/'$ICR_bin'}'`
hyper_mCG=`awk 'BEGIN{printf "%.2f", 1-'$hypo_mCG'}'`

identify_imp_status=$path/bin/identify_imprinting_status_final.pl
cal_imp_level=$path/bin/cal_imprinting_levels_CARSII.pl
cal_read_number=$path/bin/calculate_read_mCG_level.pl
cal_FPR=$path/bin/calculate_FPR.pl
cal_mCG_bin=$path/bin/calculate_mCG_by_bin.pl
merge=$path/bin/merge_list.pl

echo "Identifying preliminary DMCs and caculating read mCG numbers..."

$cal_read_number $sam_file $ICR_CG > $input\_sam_read_mCG_level.bed &

$identify_imp_status $CGI_file $sam_file > $input\_CGI_status.txt &

wait

$cal_imp_level $input\_CGI_status.txt $ICR_CG $ICR_read $ICR_bin > $input\_CGI_reads_mCG.txt

awk '{if(($2 >= '$cutoff_hypo') && ($3 >= '$cutoff_hyper')) print$0}' $input\_CGI_reads_mCG.txt > $input\_candidate_DMC_tmp1.txt

cut -f1 $input\_candidate_DMC_tmp1.txt | sed 's/_/\t/g' - > $input\_candidate_DMC_tmp1.bed

cut -f1,4 $input\_candidate_DMC_tmp1.txt > $input\_candidate_DMC_tmp1_reads.txt

intersectBed -a $CGI_file -b $input\_sam_read_mCG_level.bed -wa -wb | cut -f4,5,6,7 - | sort -k 1,1 -k 2n - > $input\_sam_read_mCG_level_CGI.bed

echo "Calculating false positive rate ..."

$cal_FPR $input\_candidate_DMC_tmp1_reads.txt $input\_sam_read_mCG_level_CGI.bed $hypo_mCG $hyper_mCG $cutoff_hypo $cutoff_hyper $test_time > $input\_candidate_DMC_tmp1_FPR.txt

echo "calculating methylation levels inside CGI ..."

$cal_mCG_bin $input\_candidate_DMC_tmp1.bed $mCG_file 2 > $input\_candidate_DMC_tmp1_mCG.txt

$merge $input\_candidate_DMC_tmp1_FPR.txt $input\_candidate_DMC_tmp1_mCG.txt > $input\_candidate_DMC_total_FPR_mCG.txt

echo "screening candidate DMCs ..."

awk '{if ($2 < '$pvalue') print$0}' $input\_candidate_DMC_total_FPR_mCG.txt | awk '{if ((($3 - $4) <= '$ICR_dif') && (($3 - $4) >= (0 - '$ICR_dif'))) print$0}' - | cut -f1,2 - | sed 's/_/\t/g' - | sort -k 1,1 -k 2n - > $input\_candidate_DMCs.bed

rm $input\_sam_read_mCG_level.bed $input\_candidate_DMC_tmp1.txt $input\_candidate_DMC_tmp1.bed $input\_candidate_DMC_tmp1_reads.txt 
rm $input\_sam_read_mCG_level_CGI.bed $input\_candidate_DMC_tmp1_FPR.txt $input\_candidate_DMC_tmp1_mCG.txt $input\_candidate_DMC_total_FPR_mCG.txt


echo "putative imprinted DMCs with FPR have been identifed out in $input\_imprinted_DMC.bed ..."

echo "putative imprinted DMCs of $input has been identified under the condition:" >> log.txt
echo "CpG number in a read should >= $ICR_CG" >> log.txt
echo "Total reads in  should >= $ICR_read" >> log.txt
echo "Reads with mCG <= $hypo_mCG were considered as hypomethylated, and mCG >= $hyper_mCG were considered as hypermethylated" >> log.txt
echo "Percentage of hypomethylated reads should >= $cutoff_hypo" >> log.txt
echo "Percentage of hypermethylated reads should >= $cutoff_hyper" >> log.txt
echo "False postive rate for each DMC should be less than $pvalue with $test_time test times " >> log.txt
echo "mCG differences inside a CGI should be less than $ICR_dif" >> log.txt












