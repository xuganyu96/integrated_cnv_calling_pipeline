# This R script should take an argument that is the path to the main directory
# and will set the working directory to the main directory
# args = commandArgs(trailingOnly=TRUE)
# path_to_main = args[1]

# Enable this line if and only if running in RStudio
running_from_rstudio <- FALSE
if(running_from_rstudio) {
  path_to_main= '/media/bruce/Stuff/File/uc-berkeley-document/job_and_internship/Jobs/veritas_genetics/main/'
  setwd(path_to_main)
}
print(getwd())

library(survival, lib.loc = "./detectors/CANOES/R_local_lib")
library(nnls, lib.loc = "./detectors/CANOES/R_local_lib")
library(Hmisc, lib.loc = "./detectors/CANOES/R_local_lib")
library(mgcv, lib.loc = "./detectors/CANOES/R_local_lib")
library(plyr, lib.loc = "./detectors/CANOES/R_local_lib")

# Read in the data and rename column names appropriately
gc <- read.table('./detectors_inputs/CANOES/gc.txt')$V2
canoes.reads <- read.table('./detectors_inputs/CANOES/canoes.reads.txt', stringsAsFactors = FALSE)
# If the fourth column of canoes.reads is string, then it is "names of the target intervals
# and hence useless
if(is.character(canoes.reads$V4)) {
  names(canoes.reads) <- c('chromosome',
                           'start',
                           'end',
                           'ivl_name')
  drops <- c("ivl_name")
  canoes.reads <- canoes.reads[ , !(names(canoes.reads) %in% drops)]
}
sample_n <- ncol(canoes.reads) - 3
sample.names <- paste('S', seq(1:sample_n), sep='')
names(canoes.reads) <- c('chromosome',
                         'start',
                         'end',
                         sample.names)
print(colnames(canoes.reads))

# Create vector of consecutive target ids:
target <- seq(1, nrow(canoes.reads))

# Combine the data into one data frame
canoes.reads <- cbind(target, gc, canoes.reads)

# All code below will be used to call CNVs
source("./detectors/CANOES/CANOES_lib.R")

# Create a vectoor to hold the results for each sample
xcnv.list <- vector('list', sample_n)

# Call CNVs for each sample
for (i in 1:sample_n) {
  xcnv.list[[i]] <- CallCNVs(sample.names[i], canoes.reads)
}

# combine the results into one data frame
xcnvs <- do.call('rbind', xcnv.list)

# Inspect the first two CNV calls
head(xcnvs, 2)
# output to file
write.csv(xcnvs, file = './detectors_outputs/CANOES/CNV_calls_canoes.csv')

# I find the plots and the genotyping to be not very important
# so I will comment them out
# # Plot all CNV calls
# pdf('./detectors_outputs/CANOES/CNVplots.pdf')
# for (i in 1:nrow(xcnvs)){
#   PlotCNV(canoes.reads, xcnvs[i, "SAMPLE"], xcnvs[i, "TARGETS"])
# }
# dev.off()

# # Genotype all the CNV calls made in the sample
# genotyping.S1 <- GenotypeCNVs(xcnvs, "S1", canoes.reads)
# # Inspect the genotype scores for the first two calls
# head(genotyping.S1, 2)
