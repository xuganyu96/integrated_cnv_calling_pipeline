#   This script is written to convert the BED-formatted CLAMMS output files into
#   a more consistent, human-readable format

import numpy as np
import pandas as pd
import os
import re

#   For format of output file, see main/TCNV_documentation
COL_NAMES = ['sample_name',
                'chromosome',
                'start',
                'stop',
                'state',
                'q_some',
                'caller']

#   The inputs of this method is all the .cnv.bed files in the output file directory
#   detectors_outputs/CLAMMS/
#   and this script will automatically scan through all the appropriate files
#   Therefore, this method will not have any arguments passed

#   Scan through all BED files within the ouput file directory and create
#   a list of paths to these BED files from main/
raw_output_directory = './detectors_outputs/CLAMMS/'
raw_output_paths = []
#   Iterate through all files within raw_output_directory
for root, dirs, files in os.walk(raw_output_directory):
    for file in files:
        #   I assume that the output directory is not to be tempered
        #   and hence only contains BED files; there is then no need
        #   to filter anything

        #   Assemble the path and append to the list
        raw_output_path = raw_output_directory + file
        raw_output_paths.append(raw_output_path)

#   For debugging
# print(raw_output_paths)
# print(sample_names)

#   Define a method that can process a single .bed file at a time
def format_single_output(raw_output_path):
    #   Takes the path from main/ to the raw output file
    #   return a pandas DataFrame object of the appropriate columns

    #   Initialize the empty output data frame
    output_df = pd.DataFrame(columns=COL_NAMES)

    #   Read in the raw output file
    raw_df = pd.read_csv(raw_output_path,
                         sep='\t',
                         header=None,
                         dtype=str)

    #   iterate through all rows of raw_df
    row_i = 0
    while row_i < raw_df.shape[0]:
        #   CLAMMS output file is of very consistent type, so I will extract information
        #   by indices unless otherwise

        #   remove the first 27 characters (directory)
        #   and the last 22 characters (".bam.no_prefix.cnv.bed")
        #   to get the desired sample name
        sample_name = raw_output_path[27:-22]

        #   CLAMMS' output removes "chr" prefix so now I will add it back
        chromosome = 'chr' + str(raw_df.iloc[row_i, 0])

        start = str(raw_df.iloc[row_i, 1])
        stop = str(raw_df.iloc[row_i, 2])
        state = str(raw_df.iloc[row_i, 5]).lower()
        q_some = str(raw_df.iloc[row_i, 8])
        #   Incase q_some is not numerical, replace with "nan"
        try:
            q_some = str(float(q_some))
        except:
            q_some = 'nan'
        caller = 'CLAMMS'
        #   Construct the row dictionary and append it to the output df
        row_dict ={'sample_name': sample_name,
                    'chromosome': chromosome,
                    'start': start,
                    'stop': stop,
                    'state': state,
                    'q_some': q_some,
                    'caller': caller}
        output_df = output_df.append(row_dict, ignore_index=True)

        row_i += 1

    return(output_df)

#   Initialize output df and iterate through all BED path, each time generating
#   a formatted df, append to output_df, and finally write to file
output_df = pd.DataFrame(columns=COL_NAMES)
for raw_output_path in raw_output_paths:
    output_df = output_df.append(format_single_output(raw_output_path),
                                 ignore_index=True)
output_df.to_csv('./detectors_outputs/clamms_calls.tcnv',
                 sep='\t',
                 index=False,
                 header=True)