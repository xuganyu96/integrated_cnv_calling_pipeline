#!/bin/bash

# This script will iterate through all normalized bed files and generate a
# single reference panel file

# Define the path to the normalized coverage bed files
# The bash script below is entirely copied from CLAMMS' github instructions
NORM_COV_BED_DIR=./detectors_inputs/CLAMMS/coverages/normalized/

ls $NORM_COV_BED_DIR | while read FILE;
do
  NORM_COV_BED_PATH="${NORM_COV_BED_DIR}${FILE}"
  echo -e -n "$NORM_COV_BED_PATH\t"
  grep "^Y" $NORM_COV_BED_PATH | awk '{ x += $4; n++; } END { if (x/n >= 0.1) print "M"; else print "F"; }'
done >./detectors_inputs/CLAMMS/ref.panel.files.txt

# Confirm the generation of the specified file
ls ./detectors_inputs/CLAMMS/*.txt
