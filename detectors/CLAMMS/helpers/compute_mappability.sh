#!/bin/bash

# Export path for GEM library
export PATH="./tools/GEM/bin/:$PATH"

# Detect the maximum number of cores in a computer and specify this number
# for fastest computation with maximum core loads
max_n_core=$((`cat /proc/cpuinfo | grep 'processor' | wc -l`))
echo "[PROGRESS] This computer has a maximum of ${max_n_core} cores; default to use all of them"

# Use GEM to compute index of the genome; use the no_prefix.fasta genome
# Specify reference genome location, number of cores used, and output location
index_input_path="./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta"
index_output_path_prefix="./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta"

# Print a confirmation message before executing the indexing computation
echo "[PROGRESS] Indexing reference genome at ${index_input_path} using ${max_n_core} cores and outputing to ${index_output_path_prefix}.gem"
gem-indexer -i ${index_input_path} \
-c "dna" \
-T ${max_n_core} \
-o ${index_output_path_prefix}
# Print a confirmation message for completing the indexing
echo "[COMPLETE] GEM indexing completed; listing files in ./detectors_inputs/CLAMMS/no_prefix_genome"
ls ./detectors_inputs/CLAMMS/no_prefix_genome/

# Specify the length of k-mers; in this case I will use 100 base pairs
kmer_length=100
gem_index_path="./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta.gem"

# Print a confirmation message before executing the mappability computation
echo "[PROGRESS] Computing mappability for ${kmer_length}-mers the reference genome using ${max_n_core} cores and outputingto main/detectors_inputs/CLAMMS/mappability.gem"
gem-mappability -T ${max_n_core} \
-I ${gem_index_path} \
-l ${kmer_length} \
-o ./detectors_inputs/CLAMMS/mappability

# Pring confirmation message and convert the mappability file to wig
echo "[PROGRESS] Converting mappability result at main/detectors_inputs/CLAMMS/mappability using index at main/detectors_inputs/CLAMMS/no_prefix_genom/no_prefix.fasta.gem and outputing to main/detectors_inputs/CLAMMS/mappability.wig"
gem-2-wig -I ./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta.gem \
-i ./detectors_inputs/CLAMMS/mappability.mappability \
-o ./detectors_inputs/CLAMMS/mappability
echo "[PROGRESS] Mappability wig output to ./detectors_inputs/CLAMMS/mappability.wig"

# Convert wig file to BED format using script from CLAMMS github documentation
# THIS GREP BASED METHOD IS INCORRECT!!!!!!! THE CODE CHUNK BELOW IS COMMENTED
# OUT TO MAKE WAY FOR AN ALTERNATIVE USING BEDOPS' WIG2BED METHOD
# echo "Converting mappability wig file at ./detectors_inputs/CLAMMS/mappability.wig to BED format, outputing to ./detectors_inputs/CLAMMS/mappability.bed"
# grep -v '^#' ./detectors_inputs/CLAMMS/mappability.wig | sed 's/^chr//g' > ./detectors_inputs/CLAMMS/mappability.bed

# Convert wig file to BED format using BEDOPS' wig2bed method
# First register BEOPS in path
export PATH="./tools/bedops-v2.4.35/bin:$PATH"
# Print a confirmation message, then start the conversion
echo "[PROGRESS] Converting wig formatted mappability data to BED format"
wig2bed < ./detectors_inputs/CLAMMS/mappability.wig \
> ./detectors_inputs/CLAMMS/mappability.bed
n_kmers=$(wc -l < ./detectors_inputs/CLAMMS/mappability.bed)
echo "[COMPLETE] Mappability scores computed for ${n_kmers} ${kmer_length}-mers and output to ./detectors_inputs/CLAMMS/mappability.bed"

# Testing if the mappability bed file is correctly computed
echo "[PROGRESS] Printing chromosome names in sorted order from ./detectors_inputs/CLAMMS/mappability.bed"
cut -f 1 ./detectors_inputs/CLAMMS/mappability.bed | uniq