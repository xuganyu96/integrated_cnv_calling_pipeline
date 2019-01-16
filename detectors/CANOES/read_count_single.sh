#~/bin/bash

# This script will take as an argument the path to a single BAM file
# and compute the read count data using bedtools

BAM_PATH=$1
filename=$(basename -- "$BAM_PATH")
extension="${filename##*.}"
sample_name="${filename%.*}" #  This removes the .bam extension

output_path="./detectors_inputs/CANOES/${sample_name}.reads.part"

echo "[PROGRESS] Computing read count data for $sample_name and outputting to $output_path"

# Invoke bedtools to compute read counts
./tools/bedtools2/bin/bedtools multicov \
-bams $BAM_PATH \
-bed `cat ./data/bed.list` \
-q 20 \
> $output_path

echo "[COMPLETE] Computed read count data for $sample_name and output written to $output_path"