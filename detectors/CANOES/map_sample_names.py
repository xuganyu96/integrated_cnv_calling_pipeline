#   This script is intended to provide a dicionary that translates between
#   CANOES' sample number and the actual sample name

#   This script is intended to be invoked by a bash script from main/

import pandas as pd

bam_list = open('./data/bam.list').read().split('\n')[:-1]

sample_names = []
#   Iterate through bam_list and extract sample name to be added to
#   sample_names.
for bam_path in bam_list:
    sample_names.append(bam_path.split('/')[-1][:-4])

#   I will format the correpondence in an n by 2 data frame
col_names = ['sample_id', 'sample_name']
corr_df = pd.DataFrame(columns = col_names)

#   Iterate through all sample_names
i = 0
while i < len(sample_names):
    sample_id = 'S' + str(i + 1)
    sample_name = sample_names[i]
    corr_df = corr_df.append({'sample_id': sample_id,
                             'sample_name': sample_name},
                             ignore_index = True)
    i += 1

#   Write to output
corr_df.to_csv('./detectors_outputs/CANOES/sample_names.csv',
               index = False)
