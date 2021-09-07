#!/bin/bash

function Usage(){
	echo "Usage:"
	echo "  TARSII_step3_germline_DMR.sh [essentials]* -p <txt> -m <txt> -b <bed> -o <output> [options] ..."
	echo ""
	echo ""
	echo "Essentials:"
	echo "-p	input txt file containing CpG methylation levels of sperm/AG early embryo in single base resolution"
	echo "-m	input txt file containing CpG methylation levels of oocyte/PG early embryo in single base resolution"
	echo "  	Note:the txt file should contain 3 columns separated by tab: 1.chr; 2.CpG pos; 3.mCG level (0~1)"
	echo ""
	echo "-b	input bed file containing imprinted DMRs generated from 'TARSII_step2_DMR_integration.sh'"
	echo "-o	output file name"
	echo ""
	echo ""
	echo "Options:"
	echo ""
	echo "-d	methylation differences for each CpG inside the early DMRs (range 0~1). Default: 0.5. "
	echo "-n	minimal CpG number contained in each early DMR. Default: 10"
	echo "-c	maximal paternal methylation levels in maternal DMRs. Default: 0.15"
	echo "-C	maximal maternal methylation levels in paternal DMRs. Default: 0.30"
	echo ""
}

if [ $# -lt 8 ]
then
	echo ""
	echo "Hi:"
	echo "	please input all the essential parameters"
	echo ""
	Usage
	exit 1
fi

path=$(cd `dirname $0`; pwd)
dif_mCG=0.5
CG_num=10
max_pat_mCG=0.15
max_mat_mCG=0.30

while getopts "p:m:b:o:d:n:c:C" opt
do
	case ${opt} in
		p)
			pat_mCG_file=$OPTARG
			;;
		m)
			mat_mCG_file=$OPTARG
			;;
		b)
			DMR_file=$OPTARG
			;;
		o)
			input=$OPTARG
			;;
		d)
			dif_mCG=$OPTARG
			;;
		n)
			CG_num=$OPTARG
			;;
		c)
			max_pat_mCG=$OPTARG
			;;
		C)
			max_mat_mCG=$OPTARG
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

merge=$path/bin/merge_list.pl
identify=$path/bin/find_early_DMR.pl

echo "processing data files ..."

awk '{printf "%s\t%.2f\n",$1"_"$2,$3}' $pat_mCG_file > $input\_pat_mCG.txt &
awk '{printf "%s\t%.2f\n",$1"_"$2,$3}' $mat_mCG_file > $input\_mat_mCG.txt &

wait

$merge $input\_pat_mCG.txt $input\_mat_mCG.txt | sed 's/_/\t/g' - > $input\_pat_mat_mCG.txt

awk '{printf "%s\t%d\t%.2f\t%.2f\t%.2f\n", $1,$2,$3-$4,$4,$3}' $input\_pat_mat_mCG.txt > $input\_pat_dif_mCG.txt &
awk '{printf "%s\t%d\t%.2f\t%.2f\t%.2f\n", $1,$2,$4-$3,$3,$4}' $input\_pat_mat_mCG.txt > $input\_mat_dif_mCG.txt &

wait

echo "identifying early embryonic DMRs ..."
$identify $input\_pat_dif_mCG.txt $dif_mCG $CG_num $max_mat_mCG > $input\_pat_hyper_early_DMR.bed &
$identify $input\_mat_dif_mCG.txt $dif_mCG $CG_num $max_pat_mCG > $input\_mat_hyper_early_DMR.bed &

wait

echo "grouping putative germline DMRs ..."
intersectBed -a $DMR_file -b $input\_pat_hyper_early_DMR.bed -wa -wb | cut -f1-3 - | sort -k 1,1 -k 2n -u - > $input\_pat_germline_DMRs.bed
intersectBed -a $DMR_file -b $input\_mat_hyper_early_DMR.bed -wa -wb | cut -f1-3 - | sort -k 1,1 -k 2n -u - > $input\_mat_germline_DMRs.bed
intersectBed -a $DMR_file -b $input\_pat_hyper_early_DMR.bed -v | intersectBed -a - -b $input\_mat_hyper_early_DMR.bed -v > $input\_somatic_DMRs.bed

rm $input\_pat_mCG.txt $input\_mat_mCG.txt $input\_pat_mat_mCG.txt $input\_pat_dif_mCG.txt $input\_mat_dif_mCG.txt
