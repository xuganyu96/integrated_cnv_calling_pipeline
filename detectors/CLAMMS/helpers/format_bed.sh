#!/bin/bash

# Add bedtools to path so it can be called directly
export PATH="./tools/bedtools2/bin:$PATH"

# Formatted BED files should be placed into an input file directory
mkdir ./detectors_inputs/CLAMMS/no_prefix_targets

# Remove "chr" prefix in target intervals BED file if needed and
# sort the chromosome orders
awk '{gsub(/^chr/,""); print}' `cat ./data/bed.list` > ./detectors_inputs/CLAMMS/no_prefix_targets/targets_unsorted.bed

bedtools sort -i ./detectors_inputs/CLAMMS/no_prefix_targets/targets_unsorted.bed > ./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed

# Check if the formatting is successful
cut -f 1 ./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed | uniq

