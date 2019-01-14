#~/bin/bash

# The one click solution to carry out all computations

# Prep data
./data_prep.sh

# Compute for individual methods
./CANOES.sh
./CLAMMS.sh
./conifer.sh

# Consolidate results to a compilation
# This python script will create the compiled/ directory if needed
# so there is no need to create more
python ./helper_methods/output_processing/call_compiler.py
echo "Compiled results output to ./detectors_outputs/compiled/compiled_calls.tcnv"

# Construct unions
python ./helper_methods/output_processing/construct_union.py
# EXPECTED output for debugging
# echo "EXPECTED 1521/54/3"