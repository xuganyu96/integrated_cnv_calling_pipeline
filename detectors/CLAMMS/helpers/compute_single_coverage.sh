#!/bin/bash

# This script will compute the depth of coverage of a single BAM file and
# output the result to a *.coverage.bed file inside the input file
# directory at
# main/detectors_inputs/CLAMMS/coverages
# This will be done by compute_coverage.sh (which is what parallelizes this
# script), so I don't need to do this here

# We need samtools for this script; export samtools' directory to PATH
export PATH="./tools/samtools-1.9/bin:$PATH"

# This script also needs to take an argument; because this script is only
# executed inside another bash script written by me, I dont' need to handle
# the exception that no argument is passed
BAM_PATH=$1

# The samtools and awk command together requires
#   -   path to the bam file
#   -   path to the output bed file
#
# path to the bam file is given by BAM_PATH so I don't need to do anything else
# But we need to construct the output bed file's file name then the file path
filename=$(basename -- "$BAM_PATH")
extension="${filename##*.}"
sample_name="${filename%.*}"
cov_bed_filename="${sample_name}.coverage.bed"
cov_bed_path="./detectors_inputs/CLAMMS/coverages/${cov_bed_filename}"

# echo $cov_bed_path

# Before computing depth of coverage, we need to index each of the no_prefix
# bamfile
echo "Indexing ${BAM_PATH}"
samtools index $BAM_PATH


# Print confirmation message and do the computation
echo "Computing depth of coverage for ${sample_name} and outputing to ${cov_bed_path}"
samtools bedcov -Q 30 \
./detectors_inputs/CLAMMS/windows.bed \
$BAM_PATH \
| awk '{ printf "%s\t%d\t%d\t%.6g\n", $1, $2, $3, $NF/($3-$2); }' \
> $cov_bed_path