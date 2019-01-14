import pandas as pd
import numpy as np
import os

#   This script is intended to process the outputs of various detectors
#   This script is to be invoked by a bash script in main/

#   The compilation is done simply by appending individual caller's formatted calls
#   onto each other; the compilation follows the same format as TCNV
#   To reduce confusion, the compiled results will be placed inside a separate
#   directory from the individual formatted results

COL_NAMES = ['sample_name',
                'chromosome',
                'start',
                'stop',
                'state',
                'q_some',
                'caller']

#   initialize the output df
output_df = pd.DataFrame(columns=COL_NAMES)

#   Scan through all TCNV files within the ouput file directory and create
#   a list of paths to these TCNV files from main/
ind_TCNV_directory = './detectors_outputs/'
ind_TCNV_paths = []
#   Iterate through all files within raw_output_directory
for root, dirs, files in os.walk(ind_TCNV_directory):
    #   only scan ind_TCNV_directory!
    if root == ind_TCNV_directory:
        for file in files:
            #   There should be individual tcnv files only
            #   Assemble the path and append to the list
            ind_TCNV_path = ind_TCNV_directory + file
            ind_TCNV_paths.append(ind_TCNV_path)

print(ind_TCNV_paths)

#   The compiled results should be placed at
#   main/detectors_outputs/compiled/compiled_calls.tcnv
outdir = './detectors_outputs/compiled/'
if not os.path.exists(outdir):
    os.mkdir(outdir)

#   iterate through all individual tcnv results
for ind_TCNV_path in ind_TCNV_paths:
    ind_df = pd.read_csv(ind_TCNV_path,
                         sep='\t',
                         header=0,
                         dtype=str)
    output_df = output_df.append(ind_df)

#   Write to tcnv
output_df.to_csv(outdir + 'compiled_calls.tcnv',
                 sep='\t',
                 index=False,
                 header=True)