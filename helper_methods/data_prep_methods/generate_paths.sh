#!/bin/bash

# This script is a wrapper for the python script generate_paths.py that
# includes the capabilities of printing error messages

# Scan the input file directories and generate paths written to
# bam.list, bed.list, and fasta.list
echo "[PROGRESS] Finding paths to raw input files"
python ./helper_methods/data_prep_methods/generate_paths.py

# Tally the number of BAM files found, then print this number for confirmation
bam_n=`wc -l < ./data/bam.list`
echo "[COMPLETE] ${bam_n} samples found in ./data/aligned_samples"

# Tally the number of lines within BED file, then print this number for
# confirmation
targets_n=`wc -l < $(cat ./data/bed.list)`
echo "[COMPLETE] ${targets_n} capture targets found in $(cat ./data/bed.list)"

# Print the path to the fasta file for confirmation message
echo "[COMPLETE] Reference genome found in $(cat ./data/fasta.list)"