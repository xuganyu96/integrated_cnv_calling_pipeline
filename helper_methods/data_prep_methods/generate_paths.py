#   This script is intended to scan through the following directories:
#   main/data/aligned_samples
#   main/data/human_genome
#   main/data/target_intervals
#
#   and output three files
#   main/data/bams.list
#   main/data/bed.list
#   main/data/fasta.list
#   on each file, each line is a path from main/ to the individual bam, bed,
#   and fasta file

#   This script is intended to be invoked by a shell script in main/

import os
import re

BAM_DIRECTORY = './data/aligned_samples/'
BED_DIRECTORY = './data/target_intervals/'
FASTA_DIRECTORY = './data/human_genome/'

bam_paths = []
#   Iterate through all files within main/data/aligned_samples
for root, dirs, files in os.walk('./data/aligned_samples'):
    for file in files:
        #   Check if this file is a BAM file
        is_BAM = re.search('.bam$', file)
        #   If it is a bamfile, attach the directory part to form appropriate
        #   path, and attach the path to the list of bam paths
        if is_BAM:
            BAM_path = BAM_DIRECTORY + file
            bam_paths.append(BAM_path)

#   Write the list to a file
with open('./data/bam.list', 'w') as f:
    for bam_path in bam_paths:
        f.write('%s\n' % bam_path)

#   Do similar things to BED and FASTA files
bed_paths = []
#   Iterate through all files within main/data/target_intervals
for root, dirs, files in os.walk('./data/target_intervals'):
    for file in files:
        #   Check if this file is a BED file
        is_BED = re.search('.bed$', file)
        #   If it is a bed file, attach the directory part to form appropriate
        #   path, and attach the path to the list of bed paths
        if is_BED:
            BED_path = BED_DIRECTORY + file
            bed_paths.append(BED_path)

#   Write the list to a file
with open('./data/bed.list', 'w') as f:
    for bed_path in bed_paths:
        f.write('%s\n' % bed_path)

fasta_paths = []
#   Iterate through all files within main/data/human_genome
for root, dirs, files in os.walk('./data/human_genome'):
    for file in files:
        #   Check if this file is a BED file
        is_FASTA = re.search('.fasta$', file)
        #   If it is a bed file, attach the directory part to form appropriate
        #   path, and attach the path to the list of bed paths
        if is_FASTA:
            FASTA_path = FASTA_DIRECTORY + file
            fasta_paths.append(FASTA_path)

#   Write the list to a file
with open('./data/fasta.list', 'w') as f:
    for fasta_path in fasta_paths:
        f.write('%s\n' % fasta_path)

