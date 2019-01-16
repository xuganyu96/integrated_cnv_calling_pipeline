#!/bin/bash

# This script is written to invoke bedtools to compute read counts
# it is separate with the GC content computation so the two steps can be
# parallelized and executed simultaneously

# print message before starting the process
echo "[PROGRESS] Computing read count data and outputing to ./detectors_inputs/CANOES/canoes.reads.txt"

# Invoke bedtools to compute read counts
cat ./data/bam.list \
| xargs -P 0 --max-args 1 \
./detectors/CANOES/read_count_single.sh

# We need another Python script for stitching individual .part read count data
# into the real canoes.reads.txt
echo "[PROGRESS] Stitching individual read count data"
python ./detectors/CANOES/stitch_reads.py
echo "[COMPLETE] Read count data stitched"

# Remove the .part files to save space
rm ./detectors_inputs/CANOES/*.part

# Print a confirmation message for finishing the process
n_targets=`wc -l < ./detectors_inputs/CANOES/canoes.reads.txt`
echo "[COMPLETE] Read count data computed for ${n_targets} capture targets"