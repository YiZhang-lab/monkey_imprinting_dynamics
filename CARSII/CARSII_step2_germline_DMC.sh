#!/bin/bash

function Usage(){
	echo "Usage:"
	echo "  CARSII_step2_germline_DMC.sh [essentials]* -p <txt> -m <txt> -b <bed> -o <output> [options] ..."
	echo ""
	echo ""
	echo "Essentials:"
	echo "-p	input txt file containing CpG methylation levels of sperm/AG early embryo in single base resolution"
	echo "-m	input txt file containing CpG methylation levels of oocyte/PG early embryo in single base resolution"
	echo "  	Note:the txt file should contain 3 columns separated by tab: 1.chr; 2.CpG pos; 3.mCG level (0~1)"
	echo ""
	echo "-b	input bed file containing candidate DMCs generated from 'CARSII_step1_DMC_identify.sh'"
	echo "-o	output file name"
	echo ""
	echo ""
	echo "Options:"
	echo ""
	echo "-d	methylation differences for each CpG inside the early DMCs (range 0~1). Default: 0.5. "
	echo "-c	maximal paternal methylation levels in maternal DMCs. Default: 0.15"
	echo "-C	maximal maternal methylation levels in paternal DMCs. Default: 0.30"
	echo ""
}

if [ $# -lt 8 ]
then
	echo ""
	echo "Hello:"
	echo "	please input all the essential parameters"
	echo ""
	Usage
	exit 1
fi

path=$(cd `dirname $0`; pwd)
dif_mCG=0.5
max_pat_mCG=0.15
max_mat_mCG=0.30

while getopts "p:m:b:o:d:c:C" opt
do
	case ${opt} in
		p)
			pat_mCG_file=$OPTARG
			if [ ! -f $pat_mCG_file ]; then
                                echo ""
                                echo "ERROR:"
                                echo "the source file $CGI_file does not exist"
                                echo ""
                                Usage
                                exit 1
                        fi
			;;
		m)
			mat_mCG_file=$OPTARG
			if [ ! -f $mat_mCG_file ]; then
                                echo ""
                                echo "ERROR:"
                                echo "the source file $CGI_file does not exist"
                                echo ""
                                Usage
                                exit 1
                        fi
			;;
		b)
			DMR_file=$OPTARG
			if [ ! -f $DMR_file ]; then
                                echo ""
                                echo "ERROR:"
                                echo "the source file $CGI_file does not exist"
                                echo ""
                                Usage
                                exit 1
                        fi
			;;
		o)
			input=$OPTARG
			;;
		d)
			dif_mCG=$OPTARG
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
cal_mCG=$path/bin/calculate_mCG_by_bin.pl

echo "calculating mCG levels in putative imprinted DMCs ..."

$cal_mCG $DMR_file $pat_mCG_file 1 > $input\_pat_mCG.txt &
$cal_mCG $DMR_file $mat_mCG_file 1 > $input\_mat_mCG.txt &

wait

echo "grouping putative imprinted DMCs ..."

$merge $input\_pat_mCG.txt $input\_mat_mCG.txt | sed 's/_/\t/g' - | sort -k 1,1 -k 2n - > $input\_pat_mat_mCG.bed

awk '{if (($4-$5 >= '$dif_mCG') && ($5 <= '$max_mat_mCG')) print$0}' $input\_pat_mat_mCG.bed | sed 's/_/\t/g' - | sort -k 1,1 -k 2n - > $input\_pat_germline_DMCs.bed

awk '{if (($5-$4 >= '$dif_mCG') && ($4 <= '$max_pat_mCG')) print$0}' $input\_pat_mat_mCG.bed | sed 's/_/\t/g' - | sort -k 1,1 -k 2n - > $input\_mat_germline_DMCs.bed

rm $input\_pat_mCG.txt $input\_mat_mCG.txt $input\_pat_mat_mCG.bed
