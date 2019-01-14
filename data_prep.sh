#!/bin/bash

# This script is intended to examine the data placed into the appropriate
# directories to ensure compatibility and generate the bamlist file to be
# placed in the data directory

# This script is intended to be run in main/

# Clean previously cached input/output files
./helper_methods/data_prep_methods/clean_cache.sh

# Generate main/data/bam.list, bed.list, and fasta.list
echo "Generating bam/bed/fast paths"
python ./helper_methods/data_prep_methods/generate_paths.py

# TEST if BAMS are sorted, and sort/index/ BAM and FASTA as needed
# Use 'T' or 'F' to specify whether you want:
# to check if BAM files are sorted
# to automatically sort BAM files if they are not sorted
# to automatically index BAM files if they are not indexed
# to automatically index FASTA file if they are not indexed
echo "Checking sortedness and indexing"
python ./helper_methods/data_prep_methods/sort_n_index.py \
-CHECK_SORT F \
-AUTO_SORT F \
-AUTO_INDEX_BAM F \
-AUTO_INDEX_FASTA F

# Compute fasta dict
echo "Computing reference genome dictionary"
echo "Removing existing dictionary"
rm ./data/human_genome/*.dict
echo "Existing dictionary removed; computing new dictionary"
java -jar ./tools/picard/picard.jar CreateSequenceDictionary \
REFERENCE=`cat ./data/fasta.list`