#!/bin/bash

# Add bedtools to path so it can be called directly
export PATH="./tools/bedtools2/bin:$PATH"

# Formatted BED files should be placed into an input file directory
mkdir ./detectors_inputs/CLAMMS/no_prefix_targets

# Print confirmation message for starting the process of removing the
# prefixes
echo "[PROGRESS] Starting to remove 'chr' prefixes from `cat ./data/bed.list`"
# Remove "chr" prefix in target intervals BED file if needed and
# sort the chromosome orders
awk '{gsub(/^chr/,""); print}' `cat ./data/bed.list` > ./detectors_inputs/CLAMMS/no_prefix_targets/targets_unsorted.bed
# Print confirmation message at the completion of this conversion
echo "[COMPLETE] Prefixes removed from chromosome names from capture targets"

# Print confirmation message at starting of sorting process
echo "[PROGRESS] Sorting formatted capture targets by chromosome names"
bedtools sort -i ./detectors_inputs/CLAMMS/no_prefix_targets/targets_unsorted.bed > ./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed
echo "[COMPLETE] Capture targets sorted by chromosome names"

# Check if the formatting is successful
echo "[COMPLETE] Printing capture targets' chromosome names in sorted order"
cut -f 1 ./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed | uniq

