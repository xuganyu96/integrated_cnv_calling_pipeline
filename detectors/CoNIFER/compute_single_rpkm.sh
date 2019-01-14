#~/bin/bash

# This script will take as an argument the path to an individual BAM file
# and output the RPKM results to
# main/detectors_inputs/CoNIFER/RPKM/*.rpkm.txt

# Take the argument that is the path to a BAM file
BAM_PATH=$1

# Define the output path; the output directory will be preemptively created
# in the parallelization script
filename_base=${BAM_PATH##*/}
filename_pref=${filename_base%.*}
# echo "${filename_pref}.rpkm.txt"
output_path="./detectors_inputs/CoNIFER/RPKM/${filename_pref}.rpkm.txt"

# Print confirmation message and make the computation
# the "completion" message will be displayed by the parallelization script
echo "Computing RPKM values for ${filename_pref} and outputing to ${output_path}"
python ./detectors/CoNIFER/conifer3.py rpkm\
  --probes ./detectors_inputs/CoNIFER/probes.txt \
  --input $BAM_PATH \
  --output $output_path
echo "RPKM value computed for ${filename_pref} and output to ${output_path}"