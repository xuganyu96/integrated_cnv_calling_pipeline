#!/bin/bash

# This script acts as a wrapper to invoke the model training script in
# main/detectors/CLAMMS/fit_models
#
# It first invokes the script that generates the reference panels, then
# invokes the fit_model script

# Define the CLAMMS directory as needed by the fit_model script
CLAMMS_DIR="./detectors/CLAMMS/"

# First invoke the reference panel generating script
./detectors/CLAMMS/helpers/ref_panels.sh

# Define the path to the reference panel text file, the windows file, and
# the output model.bed file
REF_PANEL_PATH="./detectors_inputs/CLAMMS/ref.panel.files.txt"
WINDOWS_PATH="./detectors_inputs/CLAMMS/windows.bed"
OUTPUT_MODEL_PATH="./detectors_inputs/CLAMMS/models.bed"
# Then invoke the model training
$CLAMMS_DIR/fit_models $REF_PANEL_PATH \
$WINDOWS_PATH \
>$OUTPUT_MODEL_PATH

# Print a confirmation message showing the successsful generate of the models
ls ./detectors_inputs/CLAMMS/