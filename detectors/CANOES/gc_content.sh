#!/bin/bash

# This script is intended to invoke GATK3's GC content computation
# and is separate from the read count computation so the two tasks
# can be executed simultaneously

# Print confirmation message for starting the process
echo "[PROGRESS] Computing GC Content and outputing to ./detectors_inputs/CANOES/gc.txt"

# Invoke GATK to compute GC content
java -Xmx2000m -Djava.io.tempdir=TEMP -jar ./tools/gatk-3.8-1-0/GenomeAnalysisTK.jar \
-T GCContentByInterval \
-L `cat ./data/bed.list` \
-R `cat ./data/fasta.list` \
-o ./detectors_inputs/CANOES/gc.txt

# Print a confirmation message for finishing the process
n_targets=`wc -l < ./detectors_inputs/CANOES/gc.txt`
echo "[COMPLETE] GC Content computed for ${n_targets} capture targets"