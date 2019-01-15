#!/bin/bash

# This script is written to invoke bedtools to compute read counts
# it is separate with the GC content computation so the two steps can be
# parallelized and executed simultaneously

# print message before starting the process
echo "[PROGRESS] Computing read count data and outputing to ./detectors_inputs/CANOES/canoes.reads.txt"

# Invoke bedtools to compute read counts
./tools/bedtools2/bin/bedtools multicov \
-bams `cat ./data/bam.list` \
-bed `cat ./data/bed.list` \
-q 20 \
> ./detectors_inputs/CANOES/canoes.reads.txt

# Print a confirmation message for finishing the process
n_targets=`wc -l < ./detectors_inputs/CANOES/canoes.reads.txt`
echo "[COMPLETE] Read count data computed for ${n_targets} capture targets"