#!/bin/bash

# This script will parallelize the computation of depth of coverage done by
# main/detectors/CLAMMS/helpers/compute_single_coverage.sh

# First call a helper script that will generate the list of bam files at
# main/detectors_inputs/CLAMMS/no_prefix_bam.list
python ./detectors/CLAMMS/helpers/generate_bam_list.py

# Create the input file directory that holds *.coverage.bed files
mkdir ./detectors_inputs/CLAMMS/coverages/

# Use xargs to maximize number of processes simultaneous operating on this task
echo "[PROGRESS] Initializing parallelized depth of coverage computation"
cat ./detectors_inputs/CLAMMS/no_prefix_bam.list \
| xargs -P 0 --max-args 1 \
./detectors/CLAMMS/helpers/compute_single_coverage.sh
n_covs=`ls ./detectors_inputs/CLAMMS/coverages/ | wc -l`
echo "[COMPLETE] Depth of coverage computed for ${n_covs} samples"
