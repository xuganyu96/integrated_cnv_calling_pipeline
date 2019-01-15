#!/bin/bash

# This script is intended to clean previously cached inputs and output files

# Print confirmation message for starting this process
echo "[PROGRESS] Cleaning cached input/output files from previous run"

# Remove eveything from input file directory
rm -r ./detectors_inputs/*

# Remove everything from output file directory
rm -r ./detectors_outputs/*

# Print confirmation message for finishing this process
echo "[COMPLETE] Previously cached input/output files cleaned"