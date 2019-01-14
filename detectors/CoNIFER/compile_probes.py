import sys
import pandas
import numpy as np

#   This script will read in "bed" file as a tab-delimited data frame
#   and output to a probes.txt at specified path with appropriate format
#   needed by CoNIFER

bed_path = sys.argv[1]
output_path = sys.argv[2]

#   Read the BED file as a tab delimited data frame
dtype_dict = {'chr':str,
                'start':np.int64,
                'stop':np.int64,
                'name':str}

bed_df = pandas.read_csv(bed_path,
                         sep = '\t',
                         header = None,
                         names = ['chr', 'start', 'stop', 'name'],
                         dtype = dtype_dict)

bed_df.to_csv(output_path,
              sep = '\t',
              index=False)
