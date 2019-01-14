#!/bin/bash

# This script is intended to complete the entire CLAMMS pipeline with a single
# script

###############################################################################
#############################  REFORMATTING  ##################################
###############################################################################

# CLAMMS requires that human genome file, capture target file, and sample
# alignment files have chromosome names purely numerical. Therefore, some
# reformatting is required as a first step

# Refresh the file list in main/data
python ./helper_methods/data_prep_methods/generate_paths.py

# First format the capture targets file; this should be very fast
# format_bed.sh will take the .bed file listed by main/data/bed.list
# remove the "chr" prefix if it is present, and then sort the entries
# using bedtools sort.
# The reformatted .bed file is stored at
# main/detectors_inputs/CLAMMS/no_prefix_targets/targets.bed
# Finally it will print the chromosome names for confirmation
# If the reformatting works, the output should look like
# 1
# 10
# ...
# 19
# 2
# 20
# 21
# 22
# 3
# 4
# ...
# 9
# X
# Y
# or something similar.
echo "Reformatting capture targets"
./detectors/CLAMMS/helpers/format_bed.sh

# Secondly format the human genome file ".fasta"; this should be reasonably
# fast, although slower than the previous step
# format_fasta.sh will remove all "chr" prefix from the fasta file if present
# then output the formatted .fasta file to
# main/detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta
# If the reformatting works, there should be a confirmation message that
# displays all chromosome names in the fasta file in similar fashion to below:
# >1
# >2
# ...
# >22
# >X
# >Y
echo "Reformatting human genome"
./detectors/CLAMMS/helpers/format_fasta.sh

# Thirdly format the BAM files; individual BAM file will take significant
# amount of time; fortunately, I learned a way to parallelize the computation
# by creating multiple processes so the computer can use more cores
# format_bam will take the list of bam files from data/bam.list
# and create 1 process for reformatting and indexing each original bam file
# the formatted BAM file will be output to location similar to below
# main/detectors_inputs/no_prefix_alignments/18-X-119.realigned.bam.no_prefix.bam
echo "Reformatting sample alignments"
./detectors/CLAMMS/helpers/format_bam.sh



###############################################################################
###############################  MAPPABILITY  #################################
###############################################################################

# CLAMMS takes as an input the mappability of individual base pairs on the
# reference_genome, which we need to compute

# First we need to compute binary index for the human genome FASTA file
# index_reference.sh will use the BWA software to compute the index files
# with default settings that output everything to the same directory as
# the input fasta file; in this case everything is in
# main/detectors_inputs/CLAMMS/no_prefix_genome/
echo "Creating binary index for ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta"
./detectors/CLAMMS/helpers/index_reference.sh
# This will take significant amount of time

# Secondly we will use GEM (Genomic Multitools) to
#   -   compute gem index for no_prefix.fasta
#   -   compute .mappability file
#   -   convert .mappability file to .wig file
#   -   Use wig2bed to convert .wig file to .bed file at
#       main/detectors_inputs/CLAMMS/mappability.bed
# All of this will be handled by a single script at
# main/detectors/CLAMMS/helpers/compute_mappability.sh
# This script will print a confirmation message that displays all chromosome
# names for the mappability file, which should contain 1, 10-19, 2, 20, 21, 22
# 3-9, X, Y in this order (and maybe some other none important contigs but
# they are not important)
echo "Computing mappability scores"
./detectors/CLAMMS/helpers/compute_mappability.sh


###############################################################################
#################################  WINDOWS  ###################################
###############################################################################

# CLAMMS then uses the mappability BED file and some other existing things to
# compute windows.bed at
# detectors_inputs/CLAMMS/windows.bed
# Note that in the script compute_windows.sh, the no_prefix.fasta file
# will be indexed by samtools with the output index file at
# ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta.fai
# NOTE: I tweaked calc_window_mappability to do differently if "string cannot
# be converted to float" exception occurs; check back here if results are off
#
echo "Computing windows"
./detectors/CLAMMS/helpers/compute_windows.sh

###############################################################################
##############################  DEPTH OF COV  #################################
###############################################################################

# CLAMMS next computes depth of coverage and output the results as
# 18-X-134.realigned.bam.no_prefix.coverage.bed
# inside the input file directory
# main/detectors_inputs/CLAMMS/coverages/18-X-134.realigned.bam.no_prefix.coverage.bed
# The script compute_coverage.sh will list the bed files after completing the
# computation
echo "Computing depth of coverage"
./detectors/CLAMMS/helpers/compute_coverage.sh


###############################################################################
##############################  NORMALIZATION  ################################
###############################################################################

# Normalize depth of coverage to account for GC bias and samples's overall
# average depth of coverage
# The script normalize_coverage.sh will list the .norm.cov.bed files after
# completing the normalization
echo "Normalizing depth of coverage"
./detectors/CLAMMS/helpers/normalize_coverage.sh

###############################################################################
#################################  MODELING  ##################################
###############################################################################

# Train statistical models on the normalized coverage data
# Note that train_model.sh, before training the model, first compute a file
# of reference_panels by invoking a helper method ref_panels.sh
echo "Generating reference panels and training models"
./detectors/CLAMMS/helpers/train_model.sh

###############################################################################
###############################  CALLING CNVS  ################################
###############################################################################

# Call CNVs from individual sample's normalized coverage data from the model
# This calling also specifies the gender of the individual sample by
# identifying presence of Y chromosome (or not)
# The calls are stored in BED format and output to
# main/detectors_outputs/CLAMMS/*.bed
echo "Making CNV calls"
./detectors/CLAMMS/helper/call_all_cnvs.sh

# Reformat the output using the python script
python ./helper_methods/output_processing/clamms_call_formatter.py
# print a confirmation message
n_calls=`wc -l ./detectors_outputs/clamms_calls.tcnv`
echo "${n_calls} CNV calls exported to main/detectors_outputs/clamms_calls.tcnv"