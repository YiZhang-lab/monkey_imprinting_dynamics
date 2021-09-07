#!/bin/bash

function Usage() {
	echo "Usage:" 
	echo "	TARSII_step1_DMR_identify.sh [essentials]* -x <mCG.txt> -s <sam> -o <output> [options] -n <PMD_CpG> ..."
	echo ""
	echo ""
	echo "Essentials:"
	echo ""
	echo "-x		txt file containing CpG methylation levels in single base resolution is required as input"
	echo "    		Note: the txt file contain 3 columns separated by tab: 1.chr; 2.CpG pos; 3.mCG level (0~1)"
	echo ""
	echo "-s 		sorted sam file with duplicates removed is required as input"
	echo "-o		output file name"
	echo ""
	echo ""
	echo "Options:"
	echo ""
	echo "-n	minial CpG number required for certain PMD. Default: 10"
	echo "-m	minial methylation levels for CpGs in certain PMD. Default: 0.3"
	echo "-M	maximal methylation levels for CpGs in certain PMD. Default: 0.7"
	echo "-r	mininal CpG number in a single read. Default: 3"
	echo "-l	minimal reads number aligned to each candidate DMR. Default: 30"
	echo "-b	resolution of reads mCG levels for candidate DMRs, linked to option -c/-C. Default: 5"
	echo "  	Note: -b 5 means to distribute methylated reads into 5 groups for each DMR with methylation level range from"
	echo "  	0.0-0.2, 0.2-0.4, 0.4-0.6, 0.6-0.8, 0.8-1.0. Option -c/-C with apply the cutoffs to the first/last bin"
	echo ""
	echo "-c	cutoff of percentages for hypomethylated reads versus total reads analyzed (<0.5). Default: 0.30 (30%)"
	echo "-C	cutoff of percentages for hypermethylated reads versus total reads analyzed (<0.5). Default: 0.30 (30%)"
	echo ""
}

if [ $# -lt 6 ]
then
	Usage
	exit 1
fi

path=$(cd `dirname $0`; pwd)
DMR_CG=10
DMR_min=0.3
DMR_max=0.7
ICR_CG=3
ICR_read=30
ICR_bin=5
cutoff_hypo=0.3
cutoff_hyper=0.3

while getopts "x:s:o:n:m:M:r:l:b:c:C:" opt
do
	case ${opt} in
		x)
			CG_file=$OPTARG
			if [ ! -f $CG_file ]; then
				echo ""
				echo "ERROR:"
				echo "the source file $CG_file does not exist"
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
		n)
			DMR_CG=$OPTARG
			;;
		m)
			DMR_min=$OPTARG
			;;
		M)
			DMR_max=$OPTARG
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
			

DMR_identify_extend=$path/bin/find_PMD_in_genome.pl
identify_imp_status=$path/bin/identify_imprinting_status_final.pl
cal_imp_level=$path/bin/cal_imprinting_levels.pl

echo "identifying partially methylated domains ..."

$DMR_identify_extend $CG_file $DMR_min $DMR_max $DMR_CG > $input\_PMD.bed

echo "analyzing methylated states in partially methylated domains ..."

$identify_imp_status $input\_PMD.bed $sam_file > $input\_PMD_status.txt

$cal_imp_level $input\_PMD_status.txt $ICR_CG $ICR_read $ICR_bin > $input\_PMD_reads_mCG.txt

echo "selecting candidate DMRs ..."

awk '{if(($2 >= '$cutoff_hypo') && ($3 >= '$cutoff_hyper')) print$0}' $input\_PMD_reads_mCG.txt | cut -f1 - | sed 's/_/\t/g' - > $input\_DMR_candidate.bed

rm $input\_PMD_status.txt

echo "Candidate DMR in $input has been identified under the condition:" >> log.txt
echo "PMD with minial CG number = $DMR_CG" >> log.txt
echo "PMD minimal mCG >= $DMR_min" >> log.txt
echo "PMD maximal mCG <= $DMR_max" >> log.txt
echo "CpG number in a read should >= $ICR_CG" >> log.txt
echo "Total reads in candidate DMR should >= $ICR_read" >> log.txt
echo "Methylated reads divided into groups = $ICR_bin" >> log.txt
echo "Percentage of hypomethylated reads should >= $cutoff_hypo" >> log.txt
echo "Percentage of hypermethylated reads should >= $cutoff_hyper" >> log.txt
