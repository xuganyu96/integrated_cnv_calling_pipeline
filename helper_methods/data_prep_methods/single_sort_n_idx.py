import pysam
import sys

#   This python script will take as an argument the path to a single
#   BAM file from main directory, then use samtools to check for sortedness
#   and provide for an index as needed

#   Because this script is not to be invoked by the user I will not write
#   exception handling processes

#   Read in the bam path
bam_path = sys.argv[1]

#   whether a bam file is sorted can be found using the stats command
bam_stats = ps.stats(bampath)
#   Use index() to find the result for "is_sorted:" from the output of stats command
is_sorted_result = bam_stats[bam_stats.index('is sorted')+11]
is_sorted_bool = True
#   If the result if not 1, then the bam file is not sorted
if is_sorted_result != '1':
    #   I

