#!/bin/bash

# This script is intended to format BED/BAM/FASTA files by removing "chr"
# prefix if there is such thing

# First update all file lists
python ./helper_methods/data_prep_methods/generate_paths.py

# Format BED file by removing chr prefix and sorting by chromosome
./detectors/CLAMMS/helpers/format_bed.sh

# Format Fasta file by removing chr prefix
./detectors/CLAMMS/helpers/format_fasta.sh

# Format BAM file by removing chr prefix; this script will also refresh
# bam/bed/fasta file lists again, but should not have changed anything
./detectors/CLAMMS/helpers/format_bam.sh