import pysam as ps

#   This script is intended to compute the avg insert size for the sample alignments
#   and output a recommended insert size parameter for annotate_windows.sh

#   This script is intended to be invoked from a bash script from main/

#   Import the list of bam files
#   Note that although CLAMMS will officially use the no_prefix.bam files
#   These are just the same in different format as the original ones in data/aligned_samples
#   So I will just use the original ones
bampaths = open('./data/bam.list', 'r').read().split('\n')[:-1]

read_lengths = []

#   Iterate through all bam files
for bampath in bampaths:
    # print('Counting read lengths for' + bampath)
    bamfile = ps.AlignmentFile(bampath, 'rb')

    #   Iterate through all reads of each bamfile
    for read_i in bamfile:
        read_lengths.append(read_i.query_length)

avg_read_length = float(sum(read_lengths)) / len(read_lengths)

#   This script will print the average read length rounded up by 33%
print(avg_read_length)
