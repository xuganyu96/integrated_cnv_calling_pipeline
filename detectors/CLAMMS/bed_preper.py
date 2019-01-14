#   This script will process the BED file and remove the "chr" prefix there is such
#   in the chromosome names
#   This script is intended to be invoked from a bash script from main/

import sys
import pandas as pd
import numpy as np

#   Try to read the argument passed into this script
#   if not, use the default "./data/bed.list"
bed_path = ''
try:
    bed_path = sys.argv[1]
except:
    bed_list_path = './data/bed.list'
    #   There should only be 1 BED file, so taking [0] is safe
    bed_path = open(bed_list_path, 'r').read().split('\n')[0]

#   Now that we have had the bed_path, read in the BED file as a tab-delimited dataset
target_intervals = pd.read_csv(bed_path,
                               header=None,
                               sep='\t',
                               dtype=str)

print(target_intervals)

#   Detect if first column has "chr" at the front
#   Iterate through all rows
row_i = 0
while row_i < target_intervals.shape[0]:
    chromosome = target_intervals.iloc[row_i, 0]

    #   If the chromosome name starts with "chr"
    #   remove the first three characters, and insert it back to the dataframe
    if chromosome[0:3] == 'chr':
        chromosome = chromosome[3:]
        target_intervals.iloc[row_i, 0] = chromosome
    print(row_i, chromosome)
    row_i += 1

#   Export the processed dataframe to tab delimited file again
#   This processed BED file should be stored in detectors_inputs
target_intervals.to_csv('./detectors_inputs/CLAMMS/targets.bed',
                        sep='\t',
                        header=False,
                        index=False)