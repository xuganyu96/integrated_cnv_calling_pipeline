#!/bin/bash

# This script will perform the normalization of coverage data for a single
# .coverage.bed file

# This script will take a single argument that is the path to a single
# .coverage.bed file from main/
COV_BED_PATH=$1

# Extract sample name (removing .coverage.bed)
filename=$(basename -- "$COV_BED_PATH") # This includes .coverage.bed
sample_name="${filename%.*}" #  Do once to remove .bed extension
sample_name="${sample_name%.*}" # Do again to remove the .coverage extension
norm_cov_bed_output_path="./detectors_inputs/CLAMMS/coverages/normalized/${sample_name}.norm.cov.bed"

# Print confirmation message, then perform the normalization
echo "Normalizing ${COV_BED_PATH} and outputing to $norm_cov_bed_output_path"
./detectors/CLAMMS/normalize_coverage \
$COV_BED_PATH \
./detectors_inputs/CLAMMS/windows.bed \
> $norm_cov_bed_output_path