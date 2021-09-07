# User guide for CARSII

##Note: CARSII is most efficient for identifying germline imprinting. Candidate DMCs which do not present germline methylation differences could have a relatively high false positive rate. Thus, SNP-based analysis within those non-germline imprinted DMCs identified by CARSII should be performed to confirm the imprinted states.

Please follow these steps:

1. Activate the programs:
	cd your_file_path_to_CARSII/CARSII
	chmod u+x *
	cd ./bin
	chmod u+x *

2. Prepare your files needed to process:
	1) Bed files of CpG islands
	   Should be 3 columns: <chromatin>\t<start_position>\t<end_position>\n
	   e.g. chr1	10000	12000

	2) Txt file indicating mCG levels in single base resolution in each tissue
	   Should be 3 columns: <chromatin>\t<CpG site>\t<mCG_levels(mCG/CG, from 0 to 1)>\n
	   e.g. chr1	1576	0.75

	3) Sam file generted by Bismark, sorted by chromatin position and deduplicated by MarkDuplicates(picard toolkit)
	   For raw data processing, please carefully read the related "STAR Methods" from this article:
	   
	   Otherwise your results might be inaccurate
	
	4) (if identifying germline DMCs):
	   Txt file from sperm/oocyte or AG/PG early embryos indicating mCG levels in single base resolution
           Should be 3 columns: <chromatin>\t<CpG site>\t<mCG_levels(from 0 to 1)>\n
           e.g. chr1    1576    0.75

3. Run CARSII program:

1). CARSII_step1_DMC_identify.sh -g <CpG.bed> -x <mCG.txt> -s <sam> -o <output> ... [options]

e.g.  CARSII_step1_DMC_identify.sh -g mouse_CpG_island.bed -x liver_methylome_single_base.txt -s liver_methylome.sam -o mouse_liver &

After this program, you will get 2 files:
File.1- "mouse_liver_CGI_reads_mCG.txt" containing information of all CpG islands with enough reads coverage:

File content: <chromatin_info>\t<percentage_of_hypomethylated_reads>\t<percentage_of_hypermethylated_reads>\t<total_read_number>\t<reads_number_in_each_bin>...\n

File.2- "mouse_liver_putative_imprinted_DMC.bed" with identified putative imprinted DMCs:

File content: <chromatin>\t<start_position>\t<end_position>\t<false positive rate>\n



2). CARSII_step2_germline_DMC.sh -p <txt> -m <txt> -b <bed> -o <output> ... [options]

e.g. CARSII_step2_germline_DMC.sh -p sperm_methylome_single_base.txt -m oocyte_methylome_single_base.txt -b mouse_liver_putative_imprinted_DMC.bed -o mouse_liver &

After this program, you will get 3 files that separate maternal_germline_DMCs, paternal_germline_DMCs and somatic DMCs:

File content: <chromatin>\t<start_position>\t<end_position>\t<paternal_mCG_level>\t<maternal_mCG_level>\n
	   


