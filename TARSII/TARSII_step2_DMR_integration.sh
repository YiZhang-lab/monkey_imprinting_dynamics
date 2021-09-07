#!/bin/bash

function Usage() {
	echo "Usage:"
	echo "  TARSII_step2_DMR_integration.sh [essentials] -f '<bed1> <bed2> <bed3> ...' -o <output> [options] -n <minimal_tissue_number>"
	echo ""
	echo ""
	echo "Essentials:"
	echo "-f	input bed files containing candidate DMRs identified from 'TARSII_step1_DMR_identify.sh'"
	echo "  	Note: file names should be input within '' symbol"
	echo ""
	echo "-o	output file name"
	echo ""
	echo ""
	echo "Options:"
	echo "-n        cutoff of minimal tissue number for a certain DMR to be detected in. Default: 5"
	echo ""
}

if [ $# -lt 4 ]
then
	Usage
	exit 1
fi

path=$(cd `dirname $0`; pwd)
number=5

while getopts "f:o:n:" opt
do
	case ${opt} in
		f)
			files=$OPTARG
			;;
		o)
			input=$OPTARG
			;;
		n)
			number=$OPTARG
			;;
		\?)
			echo ""
			echo "ERROR"
			echo "option not recognized"
			echo ""
			Usage
			exit 1
			;;
	esac
done

non_continuous_DMR=$path/bin/combine_non_continuous_region.pl
integration=$path/bin/identify_common_DMRs_from_multi_tissues.pl

cat $files | sort -k 1,1 -k 2n -k 3n -u -  > $input\_combined_DMR.bed

$non_continuous_DMR $input\_combined_DMR.bed > $input\_total_DMR.bed

$integration $input\_total_DMR.bed $number $files > $input\_putative_imprinted_DMR.bed

rm $input\_combined_DMR.bed $input\_total_DMR.bed

echo "TARSII predicted putative imprinted DMRs are listed in $input\_putative_imprinted_DMR.bed" >> log.txt

