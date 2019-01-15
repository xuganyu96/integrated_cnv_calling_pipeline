#!/bin/bash

# This script is intended to compute in parallel the calling of CNV from
# individual samples
# Create the output directory to put output files in
mkdir ./detectors_outputs/CLAMMS/

# Commence the computation
echo "[PROGRESS] Initializing parallelized calling of CNVs"
ls ./detectors_inputs/CLAMMS/coverages/normalized/*.norm.cov.bed \
| xargs -P 0 --max-args 1 \
./detectors/CLAMMS/helpers/call_sample_cnvs.sh
# Print confirmation message by tallying the number of cnv output files
n_outputs=`ls ./detectors_outputs/CLAMMS/ | wc -l`
echo "[COMPLETE] CNVs called on $n_outputs samples"