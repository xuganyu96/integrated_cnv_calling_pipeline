#!/bin/bash

# Make appropriate input file directory
mkdir ./detectors_inputs/CLAMMS/no_prefix_genome

# Format fasta file by removing chr prefix
cat `cat ./data/fasta.list` | sed 's/>chr/>/g' > ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta

# Check if the formatting is successful
grep '^>' -m 24 ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta