import pandas as pd
import numpy as np

#   This Python script is written to stitch individual sample's read count data
#   into a larger compilation that would be the file below:
#   ./detectors_inputs/CANOES/canoes.reads.txt

#   First we need an ordered list of raw BAM files because the order of columns
#   in canoes.reads.txt correpond to the order of paths in bam.list
bam_list_path = './data/bam.list'
bam_paths = open(bam_list_path).read().split('\n')[:-1]

#   We need the following items to complete the process:
#       1.  data from the first 4 columns, which can be found from the
#           capture target file
#       2.  individual columns taken from .part files
#       3.  output path

#   We first read in the capture targets BED file and parse into the first 4 columns
bed_path = open('./data/bed.list').read().split('\n')[0]
colnames = ['chromosome', 'start', 'stop']
rc_df = pd.read_csv(bed_path, sep = '\t', header=None)
#   Define how many columns are there in the BED file; it will be useful for
#   locating the read count column in the .part file
bed_ncol = rc_df.shape[1]

#   Then we need to convert the list of BAM file paths to the list of .part file
#   path
#   Note that a bam path always starts with './data/aligned_samples/'
#   and end with '.bam'
#   From which we can extract the file name
#   Then we add input directory and .part extension to make it the .part file path
part_dir = './detectors_inputs/CANOES/'
part_ext = '.reads.part'
part_paths = [part_dir + bam_path[23:-4] + part_ext for bam_path in bam_paths]

#   Iterate through each of the .reads.part each time taking the read count column
for part_path in part_paths:
    part_df = pd.read_csv(part_path, sep = '\t', header=None)
    count_column = part_df[bed_ncol]
    #   Assign the count column onto the read count data frame
    rc_df[part_path[26:-11]] = count_column

#   Write rc_df to canoes.reads.txt
rc_df.to_csv('./detectors_inputs/CANOES/canoes.reads.txt',
             sep='\t',
             header=False,
             index=False)
