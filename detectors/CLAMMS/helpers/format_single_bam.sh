#!/bin/bash

# This script will remove the "chr" prefix from a single BAM file taken from
# main/data/aligned_samples/*.bam
# and output the reformatted bam file to
# main/detectors_inputs/no_prefix_alignments/*.bam.no_prefix.bam

# The reformatting requires samtools, so export samtools' directory to path
export PATH="./tools/samtools-1.9/bin:$PATH"

# This script takes 1 argument that is the path to the raw BAM file from
# main/
BAM_PATH=$1

# The conversion requires a path to the unformatted BAM files (provided by
# BAM_PATH) and an output path, within which the filename will be the raw BAM
# file's filename extended by ".no_prefix.bam"
filename=$(basename -- "$BAM_PATH")
no_prefix_filename="${filename}.no_prefix.bam"
no_prefix_output_path="./detectors_inputs/CLAMMS/no_prefix_alignments/${no_prefix_filename}"

# Print a confirmation message and start reformatting
echo "Reformatting ${BAM_PATH} and outputing to ${no_prefix_output_path}"
samtools view -h $BAM_PATH \
| sed 's/chr//g' \
| samtools view -Shb - -o $no_prefix_output_path

# Compute the reformatted BAM file's index
echo "Indexing reformatted BAM file at ${no_prefix_output_path}"
samtools index ${no_prefix_output_path}

# Print a confirmation message for completing a task
echo "Reformatted and indexed file successfully output to ${no_prefix_output_path}"