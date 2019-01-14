#~/bin/bash

# Because data_prep.sh will erase everything within ./detectors_inputs/
# and ./detectors_outputs/ this script needs to create all needed directories
# before anything can be output
# The entire CoNIFER pipeline will output the following files
# ./detectors_inputs/CoNIFER/probes.txt
# ./detectors_inputs/CoNIFER/RPKM/*.rpkm.txt
# ./detectors_inputs/CoNIFER/analysis.hfdf5
# ./detectors_inputs/CoNIFER/singular_values.txt
# ./detectors_inputs/CoNIFER/sd_values.txt
# ./detectors_outputs/CoNIFER/calls.txt
# ./detectors_outputs/conifer_calls.tcnv
# However, after ./detectors_inputs/CoNIFER/ is created, compute_all_rpkm.sh
# will create the subdirectory RPKM
# As a result, the following directories need to be created
mkdir ./detectors_inputs/CoNIFER/
mkdir ./detectors_outputs/CoNIFER/

#########################################################################################################   COMPUTING PROBES  ################################
###############################################################################
# First make calls to compile_probes.py to generate probe file from BED file
echo "Converting capture targets to compatible probes at ./detectors_inputs/CoNIFER/probes.txt"
python ./detectors/CoNIFER/compile_probes.py \
`cat ./data/bed.list` \
./detectors_inputs/CoNIFER/probes.txt


###############################################################################
###########################  COMPUTING RPKM  ##################################
###############################################################################
# Compute RPKM files for each of the files
echo "Computing RPKM values"
./detectors/CoNIFER/compute_all_rpkm.sh


###############################################################################
##############################  ANALYSIS  #####################################
###############################################################################
echo "Making analysis on RPKM values"
python ./detectors/CoNIFER/conifer3.py analyze \
--probes ./detectors_inputs/CoNIFER/probes.txt \
--rpkm ./detectors_inputs/CoNIFER/RPKM/ \
--output ./detectors_inputs/CoNIFER/analysis.hfdf5 \
--svd 4 \
--write_svals ./detectors_inputs/CoNIFER/singular_values.txt \
--plot_scree ./detectors_inputs/CoNIFER/screeplot.png \
--write_sd ./detectors_inputs/CoNIFER/sd_values.txt
# echo 'Main analysis completed'

###############################################################################
##############################  CALL CNV  #####################################
###############################################################################
# echo 'making calls'
echo "Calling CNVs from analysis results"
python ./detectors/CoNIFER/conifer3.py call \
--input ./detectors_inputs/CoNIFER/analysis.hfdf5 \
--threshold 1.5 \
--output ./detectors_outputs/CoNIFER/calls.txt

# Use my python script to reformat the calls.txt file to TCNV format
python ./helper_methods/output_processing/conifer_call_formatter.py
echo "CNVs called and output to main/detectors_outputs/conifer_calls.tcnv"

###############################################################################
##############################  PLOT CNV  #####################################
###############################################################################
# mkdir ./detectors_outputs/CoNIFER/call_imgs
# # echo 'making plots'
# python ./detectors/CoNIFER/conifer3.py plotcalls \
# --input ./detectors_inputs/CoNIFER/analysis.hfdf5 \
# --calls ./detectors_outputs/CoNIFER/calls.txt \
# --outputdir ./detectors_outputs/CoNIFER/call_imgs/
# # echo 'plots made'