#!/bin/bash

# This script will check if the Picard dictionary and the samtools index
# are created for the reference genome, both of which are needed for
# later stages of analysis

ref_genome_path=`cat ./data/fasta.list`

# Do samtools indexing and Picard dictionary together
echo "[PROGRESS] Simutaneously creating samtools index and Picard dictionary for $ref_genome_path"
./tools/samtools-1.9/bin/samtools faidx $ref_genome_path &
java -jar ./tools/picard/picard.jar CreateSequenceDictionary \
REFERENCE=$ref_genome_path

# Confirm the successful creation by using ls to list files with appropriate
# extension
dict_path=$(ls ./data/human_genome/*.dict)
fai_path=$(ls ./data/human_genome/*.fai)
echo "[COMPLETE] samtools index created at ${fai_path}"
echo "[COMPLETE] Picard dictionary created at ${dict_path}"