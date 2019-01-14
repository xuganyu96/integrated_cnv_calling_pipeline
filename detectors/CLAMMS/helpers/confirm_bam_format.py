import pysam
import os
import re

#   This script will examine the chromosome names of reformatted BAM files

#   First generate a list of no_prefix.bam files and store it in input file directory
NO_PREFIX_BAM_DIR = './detectors_inputs/CLAMMS/no_prefix_alignments/'

no_prefix_bam_paths = []
#   Iterate through all files within main/data/aligned_samples
for root, dirs, files in os.walk(NO_PREFIX_BAM_DIR):
    for file in files:
        #   Check if this file is a BAM file
        is_no_prefix_BAM = re.search('.no_prefix.bam$', file)
        #   If it is a bamfile, attach the directory part to form appropriate
        #   path, and attach the path to the list of bam paths
        if is_no_prefix_BAM:
            no_prefix_BAM_path = NO_PREFIX_BAM_DIR + file
            no_prefix_bam_paths.append(no_prefix_BAM_path)

# print(no_prefix_bam_paths)
#   Write the list to a file
with open('./detectors_inputs/CLAMMS/no_prefix_bam.list', 'w') as f:
    for no_prefix_bam_path in no_prefix_bam_paths:
        f.write('%s\n' % no_prefix_bam_path)

#   Initialize a list of lists of unique reference_name
lists_of_ref_names = []
#   Iterate through all bam files
for no_prefix_bam_path in no_prefix_bam_paths:
    print("Checking chromosome names for " + no_prefix_bam_path)
    bamfile = pysam.AlignmentFile(no_prefix_bam_path, 'rb')
    unique_ref_names = list(set([read_i.reference_name for read_i in bamfile]))
    lists_of_ref_names.append(unique_ref_names)