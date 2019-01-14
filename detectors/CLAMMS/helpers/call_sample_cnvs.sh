#!/bin/bash

# This script acts as a wrapper for calling CNV from a single sample
# from

# Define the CLAMMS directory as needed by the call_cnv script
CLAMMS_DIR="./detectors/CLAMMS/"

# This script will take a single argument that is the path to a normalized
# coverage file from main; because this script will only be invoked by
# another script written by me, I will not try to handle exceptions here
NORM_COV_PATH=$1

# Extract the sample name
# e.g. 18-X-011.realigned.bam.no_prefix.norm.cov.bed
# e.g. 18-X-011.realigned.bam.no_prefix
filename=$(basename -- "$NORM_COV_PATH")
sample_name="${filename%.*}" #  Do once to remove .bed extension
sample_name="${sample_name%.*}" # Do again to remove the .coverage extension
sample_name="${sample_name%.*}" # Do again to remove the .norm extension

# Path to normalized coverage bed file is already provided by NORM_COV_PATH
# We still need to define path to model file and output file
# Note that the output of call_cnv is already in similar form to that of
# my attempted standardization of CNV calls; therefore, the output path
# will be within detectors_outputs
MODEL_PATH="./detectors_inputs/CLAMMS/models.bed"
SAMPLE_SEX=`grep "^Y" $NORM_COV_PATH | awk '{ x += $4; n++; } END { if (x/n >= 0.1) print "M"; else print "F"; }'`
OUTPUT_PATH="./detectors_outputs/CLAMMS/${sample_name}.cnv.bed"

# Print confirmation message and make calls
echo "Making CNV calls from ${sample_name} with sex option ${SAMPLE_SEX} and outputing to ${OUTPUT_PATH}"
$CLAMMS_DIR/call_cnv $NORM_COV_PATH \
$MODEL_PATH \
--sex $SAMPLE_SEX\
>$OUTPUT_PATH