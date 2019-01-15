#!/bin/bash

# Format BAM files by removing the chr prefix

export PATH="./tools/samtools-1.9/bin/:$PATH"

# The no prefix alignments should be put in a special input files directory
# main/detectors_inputs/CLAMMS/no_prefix_alignments
mkdir ./detectors_inputs/CLAMMS/no_prefix_alignments

# Give permission for format_single_bam.sh
chmod a+x ./detectors/CLAMMS/helpers/format_single_bam.sh

# Use xargs to maximize number of processes simultaneous operating on this task
echo "[PROGRESS] Initializing parallelized reformatting of raw BAM files"
cat ./data/bam.list \
| xargs -P 0 --max-args 1 \
./detectors/CLAMMS/helpers/format_single_bam.sh

# For confirmation, print the number of bam files and bai files in
# data/aligned_samples
# and
# detectors_inputs/CLAMMS/no_prefix_alignments
n_fmt_bam=`ls ./detectors_inputs/CLAMMS/no_prefix_alignments/*.bam | wc -l`
n_org_bams=`ls ./data/aligned_samples/*.bam | wc -l`
# They should be the same numbers
if [ $n_fmt_bam -eq $n_org_bams ]; then
  echo "[COMPLETE] All BAM files have been reformatted"
fi