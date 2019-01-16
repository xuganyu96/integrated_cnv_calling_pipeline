#!/bin/bash

# This script is intended to invoke bedtools (a local installation) and GATK (another local installation) to perform the data preparation and process the BAM and BED files for later use in the R script

# Invoke the read_count and gc_content script to compute read count and GC
# content together (although read count will take significantly more time)
# then GC content
echo "[PROGRESS] Simultaneously starting the computation of read count data and GC content data"
./detectors/CANOES/read_count.sh &
./detectors/CANOES/gc_content.sh

# Print a confirmation message for the end of the read_count/gc_content process
echo "[COMPLETE] All input file computation completed"

