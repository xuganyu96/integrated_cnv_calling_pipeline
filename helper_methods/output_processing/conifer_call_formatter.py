# this script is written to format the output data from conifer

import numpy as np
import pandas as pd

#   For format of output file, see main/TCNV_documentation
COL_NAMES = ['sample_name',
                'chromosome',
                'start',
                'stop',
                'state',
                'q_some',
                'caller']

#   CoNIFER's output is stored in a single file at a fixed location
raw_output_path = './detectors_outputs/CoNIFER/calls.txt'
#   Initialize the output data frame
output_df = pd.DataFrame(columns=COL_NAMES)
#   read in the raw output
raw_df = pd.read_csv(raw_output_path,
                     sep='\t',
                     header=0,
                     dtype=str)

#   Iterate through all rows
row_i = 0
while row_i < raw_df.shape[0]:
    #   Extract necessary information

    #   ".rpkm" should be removed from sampleID to produce sample name
    sample_name = raw_df['sampleID'].iloc[row_i][:-5]
    chromosome = raw_df['chromosome'].iloc[row_i]
    start = raw_df['start'].iloc[row_i]
    stop = raw_df['stop'].iloc[row_i]
    state = raw_df['state'].iloc[row_i]
    #   q_some is not available with conifer's calls
    q_some = 'nan'
    #   Assemble the row and attach onto the output data frame
    row_dict = {'sample_name': sample_name,
                'chromosome': chromosome,
                'start': start,
                'stop': stop,
                'state': state,
                'q_some': q_some,
                'caller': 'CoNIFER'}
    output_df = output_df.append(row_dict, ignore_index=True)

    row_i += 1

output_df.to_csv('./detectors_outputs/conifer_calls.tcnv',
                 sep='\t',
                 index=False,
                 header=True)