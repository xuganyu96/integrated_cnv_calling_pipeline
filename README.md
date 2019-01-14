
# Integrated CNV Calling Pipeline

## Using the Pipeline
  
**TL;DR** Do Step 1.a - 1.c and run `run_all.sh` from the terminal from the main directory with the command  
```bash
./run_all.sh
```
  
**Note** The main directory refers to the lowest-level directory that contains all files of this package. It should be the directory that contains **run_all.sh**. Unless otherwise specified, all terminal commands should be executed from the main directory.

**Individual commands**
1. Data Preparation
  1. Place sample alignment data (BAM files) into `data/aligned_samples/`; place capture target data (BED file) into `data/target_intervals/`; place reference genome (FASTA file) into `data/human_genome/`
  2. Execute the Python script `python ./helper_methods/data_prep_methods/generate_paths.py` to generate list of paths to input files
  3. If the BAM files or the FASTA file need to be indexed, run the Python script `python ./helper_methods/data_prep_methods/sort_n_index.py`
  4. Compute the reference genome dictionary file using Picard
2. CANOES pipeline
  1. Compute read count data from sample alignments and capture targets using bedtools
  2. Compute GC content of capture targets from reference genome using GATK
  3. Run the main analysis of CANOES by calling the `./detectors/CANOES/CANOES_main.R` using the `Rscript` command
  4. Construct map between sample id and sample names using the Python script `./detectors/CANOES/map_sample_names.py`
  5. Reformat CANOES' CNV call data into TCNV format and output the reformatted CNV calls into `./detectors_outputs/canoes_calls.tcnv`
3. CoNIFER pipeline
  1. Convert input capture targets file into compatible format and output to `./detectors_inputs/CoNIFER/probes.txt` using the Python script `./detectors/CoNIFER/compile_probes.py`
  2. Compute RPKM values of each of the sample by `./detectors/CoNIFER/conifer3.py`'s rpkm methods and output the RPKM value data to `./detectors_inputs/CoNIFER/RPKM/`
  3. Run the main analysis Python script that is `./detectors/CoNIFER/conifer3.py`'s analyze method
  4. Make CNV calls using `./detectors/CoNIFER/conifer3.py`'s `call` method
  5. Reformat the CNV call data into TCNV format and output to `./detectors_outputs/conifer_calls.tcnv`
4. CLAMMS pipeline
  1. Reformat capture targets data into compatible (in particular, to remove the 'chr' prefix from chromosome names if present) using the bash script `./detectors/CLAMMS/helpers/format_bed.sh` and output a sorted, no-prefix capture target data file to `./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed`
  2. Reformat reference genome (addressing the same problem as with capture targets data) and output the formatted reference genome to `./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta` using the bash script `./detectors/CLAMMS/helpers/format_fasta.sh`
  3. Reformat sample alignments (addressing the same problem as with capture targets data), output the reformatted BAM files to `./detectors_inputs/CLAMMS/no_prefix_alignments/`, use samtools to index the reformatted bam files. This is done with the bash script `./detectors/CLAMMS/helpers/format_bam.sh`
  4. Index the formatted reference genome using `BWA tools` by invoking the bash script `./detectors/CLAMMS/helpers/index_reference.sh`
  5. Compute mappability scores of individual base pair on the reference genome using the formatted reference genome and the capture targets by invoking the bash script `./detectors/CLAMMS/helpers/compute_mappability.sh`. This script will ultimately output a `mappability.bed` file at `./detectors_inputs/CLAMMS/mappability.bed`
  6. Compute windows data by invoking the bash script `./detectors/CLAMMS/helpers/compute_windows.sh`, which will output to `./detectors_inputs/CLAMMS/windows.bed`. This script will also, in the process of computing the windows, compute the samtools index of the formatted reference genome, which is output to `./detectors_inputs/CLAMMS/no_prefix_genome/no_perfix.fasta.fai`
  7. Compute the depth of coverage data for each of the sample alignments by invoking the bash script `./detectors/CLAMMS/helpers/compute_coverage.sh`. This script will output a `.coverage.bed` coverage data file for each of the sample alignment to `./detectors_inputs/CLAMMS/coverages/
  8. Normalize depth of coverage for each of the sample alignment with respect to median depth of coverage and GC content. This is done with the bash script `./detectors/CLAMMS/helpers/normalize_coverage.sh`, which, for each of the aligned sample, will output a `.nom.cov.bed` file to `./detectors_inputs/CLAMMS/coverages/normalized/`
  9. Train statistical model on the normalized depth of coverage data by invoking the bash script `./detectors/CLAMMS/helpers/train_model.sh`, which will first compute a reference panel file that is output to `./detectors_inputs/CLAMMS/ref.panel.files.txt`, then compute the statistical model, which is output to `./detectors_inputs/CLAMMS/models.bed`
  10. Make CNV calls by invoking the bash script `./detectors/CLAMMS/helper/call_all_cnvs.sh`, which will output the CNV calls to `./detectors_outputs/CLAMMS/` in the form of a single `.cnv.bed` file for each of sample alignments
  11. Reformat the CNV calls into TCNV format by calling the Python script `./helper_methods/output_processing/clamms_call_formatter.py`
5. CNV calls compilation
  1. Stack TCNV files by calling the Python script `./helper_methods/output_processing/call_compiler.py`
  2. Construct "union" instances that are representation of the consensus by calling the Python script `./helper_methods/output_processing/construct_union.py`

## Data Preparation

### Integrated bash script  
`./data_prep.sh`  
This script will invoke `generate_paths.py`, `sort_n_index.py`, and compute a reference genome dictionary using Picard. For invoking `sort_n_index.py`, four arguments named `CHECK_SORT`, `AUTO_SORT`, `AUTO_INDEX_BAM`, and `AUTO_INDEX_FASTA` are passed into the Python script via `sys.argv` and corresponds to the identically named variables described in later section on this script. For invoking Picard to compute reference genome dictionary, a `.dict` file will be written to `./data/reference_genome/`

### Generate paths to sample alignments, capture targets, and reference genome
`./helper_methods/data_prep_methods/generate_paths.py`  
`generate_paths.py` should be invoked after all input files are placed into the appropriate directories. After being invoked, the script will scan through the following three directories:
* `./data/aligned_samples/`
* `./data/target_intervals/`
* `./data/human_genome/`  

respectively looking for `.bam` files, `.fasta` file, and `.bed` file. Then the script will, for each type of files, write to a `.list` file in which each line is a path to an individual file from main directory:
* `./data/bam.list`
* `./data/bed.list`
* `./data/fasta.list`

### Sort and index sample alignments and reference genome (optional)
`./helper_methods/data_prep_methods/sort_n_index.py`
`sort_n_index.py` should be invoked after the three `.list` files have been generated. This script accomplishes a number of doublechecking on the well-formedness of input data:
* If `CHECK_SORT` is set to be true, iterate through all bam files listed by `bam.list` and use `pysam.stats()` to check if the bam file is sorted
* If `CHECK_SORT` is true and `AUTO_SORT` is set to be true, and the previous step shows that the file is not sorted, use `pysam.sort()` to sort the bam file and output to `./data/aligned_samples/[sample_name].sorted.bam` (The user needs to replace the unsorted file with the sorted file and change the filename as needed)
* If `AUTO_INDEX_BAM` is set to be true, the script will use `pysam.index()` to compute an index file for the each of the file bam listed by `bam.list` (and overwrite any existing BAM index files)
* If `AUTO_INDEX_FASTA` is set to be true, the script will use `pysam.faidx()` to compute an index file for the fasta file (and overwrite any existing FASTA index file)  

Note that this script is not efficient (does not have any form of parallelization to allow multicore processors to speed up sorting/indexing of BAM files); I still need to found better ways of doing this.

## CANOES pipeline  
CANOES is a CNV calling algorithm written in R.  

`./CANOES.sh`  
This is the script that sequentially invokes `./detectors/CANOES/CANOES_dataprep.sh` to compute read count data and GC content data, `./detectors/CANOES/CANOES_main.R` to perform the main analysis, `./detectors/CANOES/map_sample_names.py` to generate a map between sample id and sample name (see explanation in this Python script's documentation), and `./helper_methods/output_processing/canoes_call_formatter.py` to format CANOES' CNV calls into TCNV format.

`./detectors/CANOES/CANOES_dataprep.sh`  
CANOES take an inputs two files that contain read count data and GC content data, respectively computed using bedtools and GATK. `CANOES_dataprep.sh` simply calls these two tools sequentially and pass the appropriate arguments into the calling commands. bedtools will write to a file at `./detectors_inputs/CANOES/canoes.reads.txt` and GATK will write to a file at `./detectors_inputs/CANOES/gc.txt`  

`./detectors/CANOES/CANOES_main.R`  
This is the script that performs the main analysis by passing the input data to CANOES analytical methods written in and sourced from `./detectors/CANOES/CANOES_lib.R`. This script first reads in `canoes.reads.txt` and `gc.txt` and format the data into a table, then calls `CallCNVs()` from `CANOES_lib.R` to call CNVs, and ultimately write the output file to `./detectors_outputs/CANOES/CNV_calls_canoes.csv` (although by how this script is written, it will also output a pdf that contains plot for each CNV called, but it is not very important)  

`./detectors/CANOES/map_sample_names.py`  
In CANOES' main analysis, samples are represented by a numerical ID (S1, S2, ...) instead of their input file names. This Python script reconstructs a map between the numerical ID and the sample names for later reformatting's convenience. The map exists in the form of a table with two columns `sample_id` and `sample_name`, and is written to a csv file at `./detectors_outputs/CANOES/sample_names.csv`  

`./helper_methods/output_processing/canoes_call_formatter.py`  
This script converts the CNV calls made by CANOES into the TCNV format. Note that CANOES does not provide quality score for samples with more than 50 CNV calls, and `canoes_call_formatter.py` will use `nan` for this column.

## CoNIFER pipeline  
CoNIFER is a CNV calling algorithm based on a number of Python script. Its pipeline is invoked by `./conifer.sh`  

`./conifer.sh`  
This is the main script of CoNIFER's workflow. This script sequentially calls the following scripts (and their methods):
* `./detectors/CoNIFER/compile_probes.py` for converting the capture target BED file into a compatible table of probes
* `./detectors/CoNIFER/compute_all_rpkm.sh` for parallelized computation of RPKM values for each of the sample alignments
* `./detectors/CoNIFER/conifer3.py` for its `analyze` and `call` methods to respectively make CoNIFER's main analysis and make CNV calls
* `./helper_methods/output_processing/conifer_call_formatter.py` for formatting CoNIFER's CNV calls into TCNV format
* CoNIFER offers the functionality of plotting each of the CNV called, but I have commented out this section as I find the plots to contain no additional useful information.

`compile_probes.py`  
CoNIFER reads in capture target data in a slightly different format from that of a BED file. This script reads in the raw input capture target data file listed by `./data/bed.list`, adds a header to the data, then write it out to `./detectors_inputs/CoNIFER/probes.txt` 

`compute_all_rpkm.sh` and `compute_single_rpkm.sh`  
CoNIFER computes something called RPKM value for each of the sample alignments, and later uses the RPKM values for calling CNVs. Computation of RPKM value for each sample takes significant amount of time, so the two scripts work together to use the `xargs` trick to parallelize the computation.  
`compute_single_rpkm.sh` takes an argument that is the path to a BAM file listed by `./data/bam.list`, then calls `conifer3.py`'s `rpkm` method to compute RPKM value for this sample. The computed values are written to an input file at `./detectors_inputs/CoNIFER/RPKM/[sample_name].rpkm.txt`  
`compute_all_rpkm.sh` is the script that carries out the parralization of RPKM computation. It first creates the target input directory at `./detectors_inputs/CoNIFER/RPKM/` if it is not there already, then uses `xargs` to create one instace of RPKM computation for each sample, up to the maximum number allowed by the hardware and/or the OS. Finally, the script will tally the number of `.rpkm.txt` files to confirm that all RPKM values have been computed.  

`conifer3.py`  
This script is provided by the developers of CoNIFER and its `analyze` and `call` methods are used to perform the main analysis (on RPKM values) and make CNV calls that is written to `./detectors_outputs/CoNIFER/calls.txt`. However, due to that CoNIFER was scripted prior to PyTables 3.X version, and trying to use PyTables 2.X versions creates depedency problems with Numpy and Pandas, I manually changed a number of method's names to migrate conifer's main script to use PyTables 3.X versions (hence the name conifer3.py). The original Python script based on PyTables 2.X version can be found at `./detectors/CoNIFER/conifer2.py`  

`conifer_call_formatter.py`  
This script formats CoNIFER's CNV calls into the TCNV format and write the reformatted CNV calls to `./detectors_outputs/conifer_calls.tcnv`

## CLAMMS pipeline  
All files listed below, unless specified, are within the directory:  
`./detectors/CLAMMS/helpers/`

### Remove "chr" prefix from sample alignments, capture targets, and reference genome
CLAMMS' pipeline requires that all chromosome names be purely numerical, but more current reference genome data (and thus the consistently compatible sample alignments and capture target data) use a naming scheme that contains the "chr" prefix. Therefore, pre-processing of input data for removing the "chr" prefixes is necessary.  
The removal of prefixes on capture targets, reference genome, and sample alignments are respectively carried out by the following three scripts:
* `./detectors/CLAMMS/helpers/format_bed.sh`
* `./detectors/CLAMMS/helpers/format_fasta.sh`
* `./detectors/CLAMMS/helpers/format_bam.sh`
#### `format_bed.sh`  
`format_bed.sh` will first create the target input file directory at `./detectors_inputs/CLAMMS/no_prefix_targets/` if it is not there already. Then it will use `awk` command to detect and remove the chr prefix using the file listed by `./data/bed.list`. The output of the file is then written to `./detectors_inputs/CLAMMS/no_prefix_targets/targets_unsorted.bed`  
This script then proceeds to sort the unsorted capture target data by chromosome name (now 1, 2, 3, ..., 22, X, Y instead of chr1, ...) using `bedtools`' sort function. The sorted capture target data is written to `./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed`.
Finally this script will list out unique chromosome names in `./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed` in sorted order for confirming that the reformat is successful. Expect the output to be of the following form (note that order matters here):
```
1
10
11
...
19
2
20
21
22
3
4
...
9
X
Y
```
#### `format_fasta.sh`  
This script first creates the target input directory at `./detectors_inputs/CLAMMS/no_prefix_genome/` if it is not there already; the script that uses `sed` command from bash to detect and remove chr prefixes from the fasta file listed by `./data/fasta.list` and write the formatted reference genome to `./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta`. Finally, the script checks the successful formatting by listing the chromosome names within the formatted reference genome in similar fashion as in `format_bed.sh` using `grep`. Expect the output of the confirmation message to be of the form (note that order does not matter; the confirmation is good as long as there is no 'chr'):
```
>1
>2
...
>X
>Y
```
#### `format_bam.sh` and `format_single_bam.sh`
Sample alignment data need the same treatment as reference genome and capture target data. However, because BAM files are large in size and often numerous in number, processing them serially is inefficient. Therefore, `format_bam.sh` and `format_single_bam.sh` work together to create as many computation processes as `xargs` command allows to take advantage of high core count of server grade CPU.  
`format_single_bam.sh` takes an argument that is the path to an individual sample alignment within the `./data/aligned_samples/` and uses samtools and `sed` command to read the bam file, remove “chr” prefix, then write to an output file at `./detectors_inputs/CLAMMS/no_prefix_alignments/` (note that the output file has the filename format of `[sample_name].bam.no_prefix.bam`. After reformatting each sample alignment, this script will use samtools to index the reformatted BAM file for later use.  
`format_bam.sh` first creates the target input file directory at `./detectors_inputs/CLAMMS/no_prefix_alignments` if it not there already. Then it uses `xargs` to pass to `format_single_bam.sh` individual unformatted BAM file's paths (from main/) and creates as many processes as the system allows (through the option `-P 0`), each of which is a single instance of `format_single_bam.sh` processing a single unformatted BAM file.  After all BAM files are formatted, this script will print the number of BAM and BAI files in `./detectors_inputs/CLAMMS/no_prefix_alignments/` to confirm that all BAM files are formatted and indexed.
  
### Compute binary index of the formatted reference genome
#### `index_reference.sh`  
This script simply calls the BWA tools to compute the binary index for the formatted reference genome; there will be the following files produced inside `./detectors_inputs/CLAMMS/no_prefix_genome/`:
* `no_prefix.fasta.amb`
* `no_prefix.fasta.ann`
* `no_prefix.fasta.bwt`
* `no_prefix.fasta.pac`
* `no_prefix.fasta.sa`

### Compute mappability scores and annotate windows
CLAMMS takes as part its input the mappability score of individual base pairs on the reference genome and windows data
#### `compute_mappability.sh`
This is the script that sequentially calls the individual steps that lead to the output of `mappability.bed`. These steps are (in order of execution):
* `gem-indexer` for computing GEM index of the formatted reference genome. This command will write to the GEM-index files inside `./detectors_inputs/CLAMMS/no_prefix_genome/` listed below:
  * `no_prefix.fasta.gem`
  * `no_prefix.fasta.log` (not very important)
* `gem-mappability` for computing the GEM mappability score and writing it to `./detectors_inputs/CLAMMS/mappability.mappability`
* `gem-2-wig` for converting the `.mappability` file to `.wig` file at `./detectors_inputs/CLAMMS/mappability.wig`
* `wig2bed` for converting the `.wig` file to `.bed` file at `./detectors_inputs/CLAMMS/mappability.bed`
There are 2 things worth noting:
1. This script defines the length of k-mers used as input for `gem-mappability`, which can be changed according to user's need
2. This script will, at the output of `mappability.bed`, print the unique chromosome names in sorted order for confirmation of successful computation of mappability scores. Expect the output to contain "1, 10, 11, ..., 19, 2, 20, 21, 22, 3, 4, ..., 9, X, Y" in this order. There may be other contig names, but they are irrelevant and do not affect later analysis.
#### `compute_windows.sh`
This is the script that invokes CLAMMS' `annotate_windows.sh`, which takes the following inputs:
* `./detectors_inputs/CLAMMS/no_prefix_targets/targets.bed`
* `./detectors_inputs/CLAMMS/no_prefix_genome/no_prefix.fasta`
* A user specified insert size, with default value 200
* `./detectors/CLAMMS/data/clamms_special_regions.grch38.bed`, which CLAMMS provided as part of its package
and write to `./detectors_inputs/CLAMMS/windows.bed`
There are 3 things worth noting:
* The variable `INSERT_SIZE` in this script is not arbitrary and should be somewhat larger than the average read length of the sample alignments. Run the Python script `./detectors/CLAMMS/helpers/avg_insert_size.py` to compute the average read length across all samples (the script will print it out, not write to file) (the script will automatically read all bam files listed by `./data/bam.list` and requires no argument)
* The input file `./detectors/CLAMMS/data/clamms_special_regions.grch38.bed` is provided by CLAMMS to correspond to reference genome of version grch38; CLAMMS also provided a similar file in the same directory for genome version hg19. Note that these use chromosome names without "chr" prefixes
* For reasons I don't understand, `./detectors/CLAMMS/calc_window_mappability.py`, which is what `annotate_window.sh` calls for computing windows, does not play well with some of the input files (I don't know which); I added a try/except clause in `calc_window_mappability.py` to get around the problem, and although I intended this addition to not affect the results when original code works, I have not tested with other data sets and so cannot guarantee the robustness of this part.

### Compute and normalize depth of coverage  
CLAMMS takes as part of its input the depth of coverage data for sample alignments
#### `compute_coverage.sh` and `compute_single_coverage.sh`
I use samtools' `bedcov` function to compute depth of coverage of each of the window specified by `windows.bed` on each sample alignment. However, a single computation takes significant time as alignment file is large, so I use the same `xargs` trick as in `format_bam.sh` to take advantage of multicore CPU.  
`compute_single_coverage.sh` takes as an argument the path from main directory to a single `[sample_name].bam.no_prefix.bam` file, uses samtools to compute the depth of coverage data for this sample alignment, and writes the result to an input file directory at `./detectors_inputs/CLAMMS/coverages/[sample_name].bam.no_prefix.bam.coverage.bed`
`compute_coverage.sh` first calls a Python script at `./detectors/CLAMMS/helpers/generate_bam_list.py` to generate a list of `.no_prefix.bam` files inside the directory `./detectors_inputs/CLAMMS/no_prefix_alignments/` and write the list to `./detectors_inputs/CLAMMS/no_prefix_bam.list` (similar to `./data/bam.list`). The script then creates the input file directory at `./detectors_inputs/CLAMMS/coverages/`, and use `xargs` to create one instance of depth of coverage computation process for each of the no_prefix alignment, up to the maximum number of processes allowed by the system. Finally, the script lists the files inside `./detectors_inputs/CLAMMS/coverages/` for confirm the successful computation of depth of coverage data. 
#### `normalize_coverage.sh` and `normalize_single_coverage.sh`  
The depth of coverage data computed from sample alignments need to be adjusted for individual sample's media depth of coverage as well as the GC content computed by the reference genome. Normalizing coverage data sees another usage of the `xargs` trick.  
`normalize_single_coverage.sh` takes an argument that is the path to a single `[sample_name].bam.no_prefix.bam.coverage.bed` file and uses CLAMMS' `normalize_coverage` script to normalize the depth of coverage of this alignment, finally writing the normalized depth of coverage to `./detectors_inputs/CLAMMS/coverages/normalized/[sample_name].bam.no_prefix..norm.cov.bed`
`normalize_coverage.sh` creates the input file directory at `./detectors_inputs/CLAMMS/coverages/normalized/`, uses `xargs` to create instances of normalization computation processes for each of the un-normalized depth of coverage file, then list the files inside `./detectors_inputs/CLAMMS/coverages/normalized/` to confirm the successful normalization.

### Training statistical model  
This step trains the statistical model (for computing probabilistic distribution of read depths at any given base point on the reference genome)  
#### `ref_panels.sh`
This script examines the gender of each sample by looking at presence of Y chromosome and output the results to `./detectors_inputs/CLAMMS/ref.panel.files.txt`  
#### `train_models.sh`
This script invokes CLAMMS' `fit_models` script and use `ref.panel.files.txt` and `windows.bed` as inputs to construct the statistical model, which is then written to `./detectors_inputs/CLAMMS/models.bed`

### Make CNV calls
This step makes CNV calls and produce the TCNV output by applying the statistical model to the normalized depth of coverage data  
#### `call_all_cnvs.sh` and `call_sample_cnvs.sh`  
`call_sample_cnvs.sh` takes an argument taht is the path to a single normalized coverage data file inside `./detectors_inputs/CLAMMS/coverages/normalized/`, identifies the gender of the sample (using the same "detecting Y chromosome" trick as in `ref_panels.sh`), then invokes CLAMMS' `call_cnv` script to make CNV calls in the form of tab-delimited values, which are written to a BED file at `./detectors_outputs/CLAMMS/[sample_name].cnv.bed`
`call_all_cnvs.sh` creates the target output directoy at `./detectors_outputs/CLAMMS/`, uses `xargs` to create instances of CNV calling processes by passing the results of `ls ./detectors_inputs/CLAMMS/coverages/normalized/*.norm.cov.bed` to `call_sample_cnv.sh`, then output a message that says the number of samples on which CNVs are called to confirm successful calling of CNVs.
#### `clamms_call_formatter.py`  (located in `./helper_methods/output_processing/clamms_call_formatter.py`)
This Python script reads in all `./detectors_inputs/CLAMMS/coverages/normalized/*.norm.cov.bed` files and produce a single TCNV-formatted CNV calls table that incorporates calls on all samples. This table is then written to `./detectors_outputs/clamms_calls.tcnv`

## TCNV (Tabular CNV) documentation  
.tcnv will be a tab delimited rectangular data matrix with the following specification for individual columns. With Python's pandas' package, all data will be of the type "str" and numerical values to be converted to numerical data type only when computations are needed.

* column 1: sample_name  
    Sample name is defined to be the filename of the raw .bam file
    For example, for '18-X-149.realigned.bam', the sample name will be
    '18-X-149.realigned'
* column 2: chromosome  
    Name of the chromosome with the "chr" prefix
* column 3: start  
* column 4: stop  
* column 5: state  
    Either "del" or "dup", always lower case
* column 6: q_some  
    Phred-scaled quality of any CNV being in this interval  
    If not available, use "nan"
* column 7: caller  
    name of the caller algorithm

Finally, there should not be row indices, but there will be a header

## Output processing  and consensus representation
A number of scripts are written to integrate the CNV calls made by different CNV callers and to represent a consensus among the callers in intuitive ways. Unless specified, all scripts reside in `./helper_methods/output_processing/`
* `call_compiler.py`
* `union.py`
* `call.py`
* `construct_union.py`  

`call_compiler.py`  
This script simply reads in individual `.tcnv` files located in `./detectors_outputs/` as tab-delimited tables and stack the results into a larger table before writing the stacked calls to `./detectors_outputs/compiled/compiled_calls.tcnv`  

`call.py` and `union.py`  
These two defines two classes written to represent individual CNV calls and some kind of "consensus" among different CNV callers. An explanation of my representation of consensus is provided below:

### Representing consensus  
#### `call` class
A `call` instance corresponds to a single CNV call made by a single CNV caller. Such an instance contains the following instance attributes: sample_name, chromosome, start, stop, state (dup or del), and caller (name of the CNV caller). A `call` instance has an instance method `intersects`, which detects if two calls intersect with each other. The user can specify whether reciprocal intersection is required and the minimum percentage of length of overlap to qualify for intersection.  
#### `union` class  
A `union` instance corresponds to a collection of call instances such that for any pair of calls $X$ and $Y$, either $X$ and $Y$ intersect with each other, or there exists a sequence of calls $A_1, A_2, ..., A_m$ such that $X$ intersects with $A_1$, $A_1$ intersects with $A_2$, ..., and $A_m$ intersects with $Y$.  
A union instance as the following instance attribute:
* `calls`:  
a list of call instances  

A union instance has the following instance methods:
* `contains(query_call)`:  
returns True if `self.calls` contains `query_call`. The containing is there is a call instance within `self.calls` such that this call and the query call have identical sample_name, chromosome, start, stop, state, and caller attributes (and are the same call).
* `intersects_call(new_call)`:  
returns True if there exists a `call` instance in `self.calls` such that it intersects with `new_call`. Also returns True if `self` is empty.
* `add_call(new_call)`:  
append `new_call` to `self.calls` if and only if `self.calls` is empty or `self` does not contain nor intersect with `new_call`.
* `get_union_start()`:  
returns the leftmost of all starts, or -1 if `self.calls` is empty
* `get_union_stop()`:  
returns the rightmost of all stops, or -1 if `self.calls` is empty
* `get_state()`:  
returns the state of the first `call` instance in `self.calls`, or "no_calls" if `self.calls` is empty
* `count_calls()`:  
returns the number of `call` instances in `self.calls`  
* `count_callers()`:  
returns the unique number of callers present among the `call` instances in `self.calls`
* `intersects_union(union_2)`:  
returns true if there exists a `call` instance in `self.calls` and another `call` instance in `union_2.calls` such that the two `call` instances intersect
* `merges(union_2)`:  
Given 2 unions `self` and `union_2` such that they intersect, return a `union` instance that contains all unique `call` instances from the two unions. This is done by the following steps:
  * Concatenate the two lists of `call` instances `self.calls` and `union_2.calls` to get a non-unique list of `call` instances
  * Attempt to add all `call` instances from the concatenated list of `call` instances for as many times as there are many non-unique `call` instances in the concatenated list. This is to prevent the situation in which some `call` instance is not considered to intersect with the merged union until a later `call` instance is added
  
### Constructing consensus  
`construct_union.py`  
`call` and `union` classes provide a framework under which consensus can be represented, and `construct_union.py` is the script that actually finds the consensus. This is accomplished by the following steps:
* Initialize an empty list of `union` instances, called `unions`
* Read in the `compiled_calls.tcnv` as a DataFrame object and iterate through every row of the DataFrame:
  * For each row, construct a `call` instance based on the information provided by this row, and check if such a `call` instance intersects with any of the `union` instances within `unions`
      * If there is no such intersect (or if `unions` is empty), then instantiate a new `union` instance, add the `call` instance to the new `union` instance, and append the `union` instance to `unions`
      * If there is such intersection, then for each `union` instance in `unions` that intersects with this `call` instance, add this `call` instance to this `union` instance
* At this moment it is possible that there exists pairs of `union` instances that intersect each other and hence can be consolidated into a single union. Therefore we need to look for and eliminate such possibility so that the final list of `union` instances contains no intersecting `union` elements:
  * Initialize another list of `union` instances, called `cons_unions`, to contain possibly intersecting `union` instances
  * Iterate until `cons_unions` contains no intersecting `union` instances:
    * find the pair of `union` instances that intersect
    * use `merge()` method to construct the merged union, add it to `new_cons_unions` (another list of `union` instances), then remove the two `union` instances from `cons_unions`
    * concatenate what remains of `cons_unions` onto `new_cons_unions`, then replace `cons_unions` with `new_cons_unions`
    
After the process described above, `cons_unions` contains a list of `union` instances such that no two `union` elements within the lsit intersect with each other. This script will finally confirm the integrity of such representation by adding up the number of unique `call` instances among all `union` instances within `cons_unions`, which should equal to the number of rows from `compiled_calls.tcnv`
