#~/bin/bash

# The one click solution to carry out all computations

# Prep data
./data_prep_paral.sh

# Compute for individual methods
./CANOES.sh &
./CLAMMS.sh &
./conifer.sh

# Consolidate results to a compilation
# This python script will create the compiled/ directory if needed
# so there is no need to create more
echo "[PROGRESS] Compiling calls from individual callers"
python ./helper_methods/output_processing/call_compiler.py
# Tally the number of compiled calls and print completion message
n_calls=`wc -l < ./detectors_outputs/compiled/compiled_calls.tcnv`
echo "[COMPLETE] Compiled $n_calls calls"

# Construct unions
python ./helper_methods/output_processing/construct_union.py
# EXPECTED output for debugging
# echo "EXPECTED 1521/54/3"