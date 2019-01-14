#!/bin/bash


# The normalized coverage data will be put in an input file directory at
# main/detectors_inputs/CLAMMS/coverages/normalized
mkdir ./detectors_inputs/CLAMMS/coverages/normalized/

# Parallelize individual normalization
ls detectors_inputs/CLAMMS/coverages/*.coverage.bed \
| xargs -P 0 --max-args 1 \
./detectors/CLAMMS/helpers/normalize_single_coverage.sh

# List the files inside main/detectors_inputs/CLAMMS/coverages/normalized
# as a confirmation message
ls ./detectors_inputs/CLAMMS/coverages/normalized/