#   This script is intended to check if the BAM files are sorted and indexed

#   This script is intended to be invoked by a bash script in main/

import pysam as ps
import sys

#   if AUTO_SORT is true, then encounterance with any unsorted BAM file
#   will trigger pysam to sort it and out
CHECK_SORT = False
AUTO_SORT = False
AUTO_INDEX_BAM = False
AUTO_INDEX_FASTA = False

#   Test if there is system inputs; note that argv[1] is filename
sys_inputs = sys.argv[1:]
CHECK_SORT_response = sys_inputs[sys_inputs.index('-CHECK_SORT')+1]
AUTO_SORT_response = sys_inputs[sys_inputs.index('-AUTO_SORT')+1]
AUTO_INDEX_BAM_response = sys_inputs[sys_inputs.index('-AUTO_INDEX_BAM')+1]
AUTO_INDEX_FASTA_response = sys_inputs[sys_inputs.index('-AUTO_INDEX_FASTA')+1]

if CHECK_SORT_response == 'T':
    CHECK_SORT = True
if AUTO_SORT_response == 'T':
    AUTO_SORT = True
if AUTO_INDEX_BAM_response == 'T':
    AUTO_INDEX_BAM = True
if AUTO_INDEX_FASTA_response == 'T':
    AUTO_INDEX_FASTA = True

if CHECK_SORT:
    print("Sortedness will be checked")
else:
    print("Sortedness will not be checked")
if AUTO_SORT:
    print("Unsorted BAM files will be automatically sorted")
else:
    print("Unsorted BAM files will not be automatically sorted")
if AUTO_INDEX_BAM:
    print("BAM files will be automatically indexed")
else:
    print("BAM files will not be automatically indexed")
if AUTO_INDEX_FASTA:
    print("FASTA files will be automatically indexed")
else:
    print("FASTA files will not be automatically indexed")


#   Read in the bamlist
bamlist = open('./data/bam.list').read().split('\n')
fasta_list = open('./data/fasta.list').read().split('\n')
#   Trim the last empty space
if len(bamlist[-1]) == 0:
    bamlist = bamlist[:-1]
if len(fasta_list[-1]) == 0:
    fasta_list = fasta_list[:-1]

if CHECK_SORT:
    #   For each of the bamfile, use ps.stats() to check if the file is sorted
    is_sorted_results = []
    for bampath in bamlist:
        print('Checking if ' + bampath + ' is sorted')
        bam_stats = ps.stats(bampath)
        #   Use index() to find the result for "is_sorted:"
        is_sorted_result = bam_stats[bam_stats.index('is sorted')+11]
        is_sorted_results.append(is_sorted_result)
        if is_sorted_result == '1':
            print(bampath + ' is sorted')
        else:
            print(bampath + ' is not sorted')
            #   automatically triger the sorting process if AUTO_SORT is set true
            if AUTO_SORT:
                ps.sort('-o', bampath[:-4] + '.sorted.bam', bampath)


#   User can specify whether they want this script to generate index files
#   for the BAM files
if AUTO_INDEX_BAM:
    print("Indexing BAM files")
    for bampath in bamlist:
        print("Indexing " + bampath)
        ps.index(bampath)

#   User can specify whether they want this script to geneate index files
#   for the FASTA file
if AUTO_INDEX_FASTA:
    print("Indexing FASTA files")
    for fasta_path in fasta_list:
        print("Indexing " + fasta_path)
        ps.faidx(fasta_path)

