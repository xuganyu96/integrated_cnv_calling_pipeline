#!/bin/bash


# The normalized coverage data will be put in an input file directory at
# main/detectors_inputs/CLAMMS/coverages/normalized
mkdir ./detectors_inputs/CLAMMS/coverages/normalized/

# Parallelize individual normalization
echo "[PROGRESS] Initializing parallelized normalization of depth of coverage data"
ls detectors_inputs/CLAMMS/coverages/*.coverage.bed \
| xargs -P 0 --max-args 1 \
./detectors/CLAMMS/helpers/normalize_single_coverage.sh

# List the files inside main/detectors_inputs/CLAMMS/coverages/normalized
# as a confirmation message
n_normed=`ls ./detectors_inputs/CLAMMS/coverages/normalized/ | wc -l`
echo "[COMPLETE] $n_normed samples' depth of coverage normalized"