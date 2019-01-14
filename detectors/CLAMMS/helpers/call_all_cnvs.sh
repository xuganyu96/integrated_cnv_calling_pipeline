#!/bin/bash

# This script is intended to compute in parallel the calling of CNV from
# individual samples
# Create the output directory to put output files in
mkdir ./detectors_outputs/CLAMMS/

# Commence the computation
ls ./detectors_inputs/CLAMMS/coverages/normalized/*.norm.cov.bed \
| xargs -P 0 --max-args 1 \
./detectors/CLAMMS/helpers/call_sample_cnvs.sh

# Pring a confirmation message for successful computation of CNV calls
n_outputs=`ls ./detectors_outputs/CLAMMS/ | wc -l`
echo "${n_outputs} samples examined and their CNVs called"