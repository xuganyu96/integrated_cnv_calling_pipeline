#!/bin/bash

# This script contains the following steps as the workflow for prepping input
# data for later use by individual CNV callers
#
# clean_cache
# generate_paths
# check BAM sortedness -> index the BAM files
# check and index fasta file
# create fasta dictionary

# Remove all files and subdirectories within ./detectors_inputs/ and
# ./detectors_outputs/ and generate paths to individual BAM/BED/FASTA file
# from main directory
./helper_methods/data_prep_methods/clean_cache.sh

# Call the bash script to generate and verify paths to raw input files
./helper_methods/data_prep_methods/generate_paths.sh

# Call the bash script to check and index/dict the reference genome as needed
# by later steps in the pipeline
./helper_methods/data_prep_methods/prep_ref_genome.sh

# Print a final mesage for confirming the completion of all steps in this
# script
echo "[COMPLETE] All data preparation is completed"





