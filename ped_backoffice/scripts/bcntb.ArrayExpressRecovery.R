### bcntb.ArrayExpressRecovery.R ###
### DESCRIPTION ########################################################
# This script change the column names of the ArrayExpress dataframe, according to
# the created target file (useful for later analysis)
# it is a rescue script!

### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0			2017/06/12			Stefano					this is just a rescue script, for the ArrayExpress!

### PARAMETERS #######################################################
current_dir <- getwd()
suppressMessages(library(optparse))

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-p", "--pmid"), action="store", default=NA, type='character',
              help="pmid to retrieve the correct ArrayExpress matrix "),
  make_option(c("-s", "--sdrf"), action="store", default=NA, type='character',
              help="sdrf file to map the correct GSM file on the array express matrix"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

## initialising directories and files to load
root_dir = paste(opt$dir, "", sep='/')
norm_dir = paste(opt$dir, "norm_files", sep='/')
expr_fn = paste(norm_dir,opt$pmid,'.ae.processed.txt',sep='')
target_fn = paste(root_dir,"target.txt", sep='')

### retrieving files
setwd(root_dir)
system(paste("find . -name '*.processed.*.zip' | xargs -n1 unzip -d ",norm_dir,'/',sep = ''))

## UPDATE 2017/06/12 -- prepare for data recovery
# renaming file according to a standard nomenclature (easy to recover the file)
# nomenclature = <PMID>.ae.processed.txt
setwd(norm_dir)
system(paste("for file in $(find . -name '*processed*'); do mv $file ",opt$pmid,".ae.processed.txt; done",sep=""))

# reading the ArrayExpress matrix
expr_file <- read.table(expr_fn, sep='\t', header=TRUE, stringsAsFactors = FALSE, row.names=NULL)

# reading the target file
sdrf_file <- read.table(target_fn, sep='\t', header=TRUE, stringsAsFactors = FALSE, row.names=NULL)

# saving all the columns names into an array
ae_sample_names = colnames(expr_file)

# for each column of the expr_file we search into the sdrf file the corrensponding GSM name
cont = 1
for (ae_sn in ae_sample_names) {
  # retrieve the row where the ArrayExpress column name has been found
  found_line = sdrf_file[apply(sdrf_file, 1, function(r) any(r %in% ae_sn)),]

  # searching for GSM name inside the matched row
  gsm_file = grep("",found_line, value = TRUE, ignore.case = false)[[1]]

  # update the column name for the Array Express expression file
  colnames(expr_file)[i] = gsm_file
  cont = cont + 1
}

# saving updated expression file to the same file
write.table(expr_file, file=expr_fn, sep='\t', quote=FALSE, row.names=FALSE, col.names=TRUE, eol='\n')
