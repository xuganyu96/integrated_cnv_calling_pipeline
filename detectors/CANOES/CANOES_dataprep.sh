#!/bin/bash

# This script is intended to invoke bedtools (a local installation) and GATK (another local installation) to perform the data preparation and process the BAM and BED files for later use in the R script

# If the script is invoked from a terminal/script in /main directory, then this script will execute as if it were in /main directory; therefore, I will write this script as if it is in main directory

# Test the output of the cat command from bash
# cat bamlist_full

# It is not guaranteed that the output directories are going to be there

###############################################################################
#########################  COMPUTE READ COUNTS  ###############################
###############################################################################
# Invoke bedtools to compute read counts
./tools/bedtools2/bin/bedtools multicov \
-bams `cat ./data/bam.list` \
-bed `cat ./data/bed.list` \
-q 20 \
> ./detectors_inputs/CANOES/canoes.reads.txt

echo 'END OF BEDTOOLS'


###############################################################################
##########################  COMPUTE GC CONTENT  ###############################
###############################################################################
# Invoke GATK to compute GC content
java -Xmx2000m -Djava.io.tempdir=TEMP -jar ./tools/gatk-3.8-1-0/GenomeAnalysisTK.jar \
-T GCContentByInterval \
-L `cat ./data/bed.list` \
-R `cat ./data/fasta.list` \
-o ./detectors_inputs/CANOES/gc.txt

# This would be the end of the data prep phase