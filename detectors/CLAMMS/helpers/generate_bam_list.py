import os
import re

#   This script will generate a list of no_prefix_bam paths and write
#   the list to main/detectors_inputs/CLAMMS/no_prefix_bam.list

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