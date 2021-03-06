#!/bin/bash

# This script is intended to invoke annotate_windows.sh to compute windows.bed
# and is intended to be run from main/

# First add bedtools to path as annotate_windows.sh requires it
export PATH="./tools/bedtools2/bin/:$PATH"

# Define INSERT_SIZE using the output from avg_insert_size.py
INSERT_SIZE=200

# Give permission to bash script in CLAMMS
chmod a+x ./detectors/CLAMMS/*.sh

# Declare CLAMMS_DIR var required by annotate_windows.sh
export CLAMMS_DIR="./detectors/CLAMMS/"

# annotate_windows.sh also requires fai file
echo "[PROGRESS] Indexing ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta"
./tools/samtools-1.9/bin/samtools faidx ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta
echo "[COMPLETE] ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta indexed"


# Run the annotate_windows.sh script
echo "[PROGRESS] Annotating windows and outputing to ./detectors_inputs/CLAMMS/windows.bed"
./detectors/CLAMMS/annotate_windows_w_debug.sh \
./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed \
./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta \
./detectors_inputs/CLAMMS/mappability.bed \
$INSERT_SIZE \
./detectors/CLAMMS/data/clamms_special_regions.grch38.bed \
> ./detectors_inputs/CLAMMS/windows.bed
n_windows=`wc -l < ./detectors_inputs/CLAMMS/windows.bed`
# Print confirmation message for completing the annotation
echo "[COMPLETE] ${n_windows} windows annotated"