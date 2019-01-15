#!/bin/bash

# Make appropriate input file directory
mkdir ./detectors_inputs/CLAMMS/no_prefix_genome

# Format fasta file by removing chr prefix
echo "[PROGRESS] Removing 'chr' prefixes from `cat ./data/fasta.list`"
cat `cat ./data/fasta.list` | sed 's/>chr/>/g' > ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta
echo "[COMPLETE] Prefixes removed from chromosome names in reference genome"

# Check if the formatting is successful
echo "[COMPLETE] Printing reference genome's chromosome names"
grep '^>' -m 24 ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta