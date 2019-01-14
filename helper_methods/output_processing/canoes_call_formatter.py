#   This script is written to convert the CSV formatted CANOES cnv calls to tcnv format
#   as specified by main/TCNV_documentation

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

#   CANOES' output is stored in a single file at a fixed location
raw_output_path = './detectors_outputs/CANOES/CNV_calls_canoes.csv'
#   also, read in the sample_names.csv and construct the sample_id - sample_name
#   dictionary
sample_name_map_path = './detectors_outputs/CANOES/sample_names.csv'
sample_name_map_df = pd.read_csv(sample_name_map_path,
                                 sep=',',
                                 header=0,
                                 dtype=str)
sample_name_dict = dict()
row_i = 0
while row_i < sample_name_map_df.shape[0]:
    sample_id = sample_name_map_df['sample_id'].iloc[row_i]
    sample_name = sample_name_map_df['sample_name'].iloc[row_i]
    sample_name_dict[sample_id] = sample_name
    row_i += 1

#   for debugging
# print(sample_name_dict)

#   Initialize the output data frame
output_df = pd.DataFrame(columns=COL_NAMES)
#   read in the raw output
raw_df = pd.read_csv(raw_output_path,
                     sep=',',
                     header=0,
                     dtype=str)

#   Iterate through all rows
row_i = 0
while row_i < raw_df.shape[0]:
    #   Extract necessary information
    sample_id = raw_df['SAMPLE'].iloc[row_i]
    sample_name = sample_name_dict[sample_id]
    interval = raw_df['INTERVAL'].iloc[row_i]
    colon_idx = interval.index(':')
    dash_idx = interval.index('-')
    chromosome = 'chr' + str(interval[0:colon_idx])
    start = interval[(colon_idx+1):dash_idx]
    stop = interval[(dash_idx+1):]
    state = raw_df['CNV'].iloc[row_i].lower()
    q_some = raw_df['Q_SOME'].iloc[row_i]
    #   Guard against nan
    try:
        q_some = str(float(q_some))
    except:
        q_some = 'nan'
    caller = 'CANOES'
    #   Assemble the row and attach onto the output data frame
    row_dict = {'sample_name': sample_name,
                'chromosome': chromosome,
                'start': start,
                'stop': stop,
                'state': state,
                'q_some': q_some,
                'caller': caller}
    output_df = output_df.append(row_dict, ignore_index=True)

    row_i += 1

output_df.to_csv('./detectors_outputs/canoes_calls.tcnv',
                 sep='\t',
                 index=False,
                 header=True)