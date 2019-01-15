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

# The data prep script already contains all output messages so I won't write
# more
./detectors/CANOES/CANOES_dataprep.sh

###############################################################################
#######################  ANALYSIS AND OUTPUT  #################################
###############################################################################
echo "[PROGRESS] Making main analysis"
Rscript ./detectors/CANOES/CANOES_main.R
# Print a confirmation message as to how many CNVS are called
n_cnv_called=$(wc -l < ./detectors_outputs/CANOES/CNV_calls_canoes.csv)
echo "[COMPLETE] ${n_cnv_called} CNVs called by CANOES"

# Map sample names
echo "[PROGRESS] Mapping sample IDs and names"
python ./detectors/CANOES/map_sample_names.py
echo "[COMPLETE] Sample IDs and names mapped"

# Reformat outputs to TCNV format
echo "[PROGRESS] Reformatting output results to TCNV"
python ./helper_methods/output_processing/canoes_call_formatter.py
echo "[COMPLETE] Reformatted calls output to main/detectors_outputs/canoes_calls.tcnv"