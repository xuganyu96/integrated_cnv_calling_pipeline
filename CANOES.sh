#!/bin/bash

###############################################################################
#########################  DATA PREPARATION  ##################################
###############################################################################
# Because ./data_prep.sh contains a step that deletes everything within
# ./detectors_inputs/
# ./detectors_outputs/
# When CANOES.sh is called, we need to construct these input/output file
# locations
# The entire CANOES pipeline will output to the following files
# ./detectors_inputs/CANOES/canoes.reads.txt
# ./detectors_inputs/CANOES/gc.txt
# ./detectors_outputs/CANOES/CNV_calls_canoes.csv
# ./detectors_outputs/CANOES/CNVplots.pdf
# Therefore the following two directories need to be made
mkdir ./detectors_inputs/CANOES/
mkdir ./detectors_outputs/CANOES/

echo "Computing canoes.reads.txt and gc.txt"
./detectors/CANOES/CANOES_dataprep.sh

###############################################################################
#######################  ANALYSIS AND OUTPUT  #################################
###############################################################################
echo "Making main analysis"
Rscript ./detectors/CANOES/CANOES_main.R

# Map sample names
echo "Mapping sample IDs and names"
python ./detectors/CANOES/map_sample_names.py

# Reformat outputs to TCNV format
echo "Reformatting output results to TCNV"
python ./helper_methods/output_processing/canoes_call_formatter.py
echo "Reformatted calls output to main/detectors_outputs/canoes_calls.tcnv"