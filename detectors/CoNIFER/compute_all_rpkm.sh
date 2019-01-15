#~/bin/bash

# This script will parallelize the computation of RPKM values from BAM files
# by using xargs and creating multiple processes for multi-core processors
# to handle

# Create the input directory to place the *.rpkm.txt files
mkdir ./detectors_inputs/CoNIFER/RPKM/

# Conduct the parallelization
echo "[PROGRESS] Initializing parallelized computation of RPKM values"
cat ./data/bam.list \
| xargs -P 0 --max-args 1 \
./detectors/CoNIFER/compute_single_rpkm.sh

# Print confirmation message
n_rpkm=`ls ./detectors_inputs/CoNIFER/RPKM/*.txt | wc -l`
echo "[COMPLETE] RPKM values computed for ${n_rpkm} samples"