#!/bin/bash

# This script is intended to format all raw input file by eliminating the
# "chr" prefixes from chromosome names

# Using & to run all three formatting tasks together
echo "[PROGRESS] Simultaneously starting to format BED, BAM, and FASTA files"
./detectors/CLAMMS/helpers/format_bed.sh &
./detectors/CLAMMS/helpers/format_fasta.sh &
./detectors/CLAMMS/helpers/format_bam.sh
echo "[COMPLETE] Finished all formatting of raw input files"