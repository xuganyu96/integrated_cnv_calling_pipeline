#~/bin/bash

# The one click solution to carry out all computations

# Prep data
./data_prep.sh

# Compute for individual methods
./CANOES.sh
./CLAMMS.sh
./conifer.sh

# Consolidate results to a compilation
python ./helper_methods/output_processing/call_compiler.py
echo "Compiled results output to ./detectors_outputs/compiled/compiled_calls.tcnv"

# Construct unions
python ./helper_methods/output_processing/construct_union.py
# EXPECTED output
echo "EXPECTED 1521/54/3"