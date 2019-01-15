#!/bin/bash

# This script is to be executed in parallel with GC content computation
# and read count computation. Because read count computation takes significant
# time, I would like to have a way of displaying current progress.

# This done by examining the output file at
# ./detectors_inputs/CANOES/canoes.reads.txt
# Because this file is written line by line, each line representing a capture
# target; bedtools will write read counts target by target, so the number of
# lines written is a directly reflection of how much work is done

# This script will use wc -l to count the number of lines in this file
# and print such number along side the number of capture targets as a
# measurement of progress with read count data computation

# Count the number of capture targets specified in target_intervals
n_targets=$(wc -l < `cat ./data/bed.list`)

# Initialize the count variable for counting number of lines in
# ./detectors_inputs/CANOES/canoes.reads.txt
n_processed=0

# Specify the wait time between updates
sleep_sec=0.5

# Do a while loop:
# while the number of capture targets processsed is less than the number of
# targets specified, update the number of capture targets processed,
# print the current progress, then sleep for 1 second
while [ $n_processed -lt $n_targets ]; do
  # Update the number of lines in reads.canoes.txt
  n_processed=$(wc -l < ./detectors_inputs/CANOES/canoes.reads.txt)
  # Print the current progress
  echo "[PROGRESS] Read count computed for ${n_processed} / ${n_targets} intervals"
  # Sleep for specified number of seconds
  sleep $sleep_sec
done

# Print a confirmation message for completing the computation of read count
# data
echo "[COMPLETE] Read count computed for ${n_processed} capture targets"

