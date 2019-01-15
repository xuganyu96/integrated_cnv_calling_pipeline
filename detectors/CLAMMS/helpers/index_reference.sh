#!/bin/bash

# This script is intended to invoke bwa tools to compute the index files for
# the genome
# Note that we want to use the one that is reformatted
# which means its path is fixed:
# main/detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta

echo "[PROGRESS] Creating binary index for ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta"
./tools/bwa-0.7.17/bwa index ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta
echo "[COMPLETE] Binary index created for ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta"