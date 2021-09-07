# User guide for TARSII

Please follow these steps:

1. Activate the programs:
        cd your_file_path_to_CARSII/CARSII
        chmod u+x *
        cd ./bin
        chmod u+x *

2. Prepare your files needed to process:
        1) Txt file indicating mCG levels in single base resolution in each tissue
           Should be 3 columns: <chromatin>\t<CpG site>\t<mCG_levels(mCG/CG, from 0 to 1)>\n
           e.g. chr1    1576    0.75

        2) Sam file generted by Bismark, sorted by chromatin position and deduplicated by MarkDuplicates(picard toolkit)
           For raw data processing, please carefully read the related "STAR Methods" from this article:

           Otherwise your results might be inaccurate

        3) (if identifying germline DMCs):
           Txt file from sperm/oocyte or AG/PG early embryos indicating mCG levels in single base resolution
           Should be 3 columns: <chromatin>\t<CpG site>\t<mCG_levels(from 0 to 1)>\n
           e.g. chr1    1576    0.75

3. Run TARSII program:

1). TARSII_step1_DMR_identify.sh -x <mCG.txt> -s <sam> -o <output> [options] ...

e.g. TARSII_step1_DMR_identify.sh -x liver_methylome_single_base.txt -s liver_methylome.sam -o mouse_liver &

After this program, you will get 3 files:

File.1 - "mouse_liver_PMD.bed" contains partially methylated domains identified out
File content: <chromatin>\t<start>\t<end>\t<average_mCG>\n

File.2 - "mouse_liver_PMD_reads_mCG.txt" contains all PMDs identified and analyzed
File content: <chromatin_info>\t<percentage_of_hypomethylated_reads>\t<percentage_of_hypermethylated_reads>\t<reads_number_in_each_bin>...\n

File.3 - "mouse_liver_DMR_candidate.bed"
File content: <chromatin>\t<start>\t<end>\n"



2) TARSII_step2_DMR_integration.sh -f '<bed1> <bed2> <bed3> ...' -o <output> [options] ...

e.g. TARSII_step2_DMR_integration.sh -f 'Mouse_liver_DMR_candidate.bed Mouse_brain_DMR_candidate.bed Mouse_kidney_DMR_candidate.bed ...' -o mouse_tissue -n 5

After the program, you will get 1 file:

File.1 - "mouse_tissue_putative_imprinted_DMR.bed" contains imprinted DMRs identifed by TARSII
File content: <chromatin>\t<start>\t<end>\n



3) TARSII_step3_germline_DMR.sh -p <pat_mCG.txt> -m <mat_mCG.txt> -b <bed> -o output [options] ...

e.g. TARSII_step3_germline_DMR.sh -p sperm_methylome_single_base.txt -m oocyte_methylome_single_base.txt -b mouse_tissue_putative_imprinted_DMR.bed -o mouse &

After the program, you will get 5 files:

File.1 - "mouse_pat_hyper_early_DMR.bed" contains paternal-allele-methylated DMRs
File content: <chromatin>\t<start>\t<end>\t<maternal_mCG>\t<paternal_mCG>\n

File.2 - "mouse_mat_hyper_early_DMR.bed" contains maternal-allele-methylated DMRs
File content: <chromatin>\t<start>\t<end>\t<paternal_mCG>\t<maternal_mCG>\n

File. 3-5 - maternal_germline_DMRs, paternal_germline_DMRs and somatic_DMRs:
File content: <chromatin>\t<start>\t<end>\n
