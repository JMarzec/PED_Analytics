### bcntb.pam50.R ###
### DESCRIPTION ########################################################
# This script makes predicts PAM50 breast cancer subtypes using expression matrix
# Used in the BCCTB analysis tools interface to produce PAM50 subtypes

### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0			2017/04/18			Stefano					optimized from 2015/06/16 Emanuela's version

### PARAMETERS #######################################################
current_dir <- getwd()
suppressMessages(source(paste(current_dir,"scripts/bcntb.functions.R",sep = "/")))
suppressMessages(library(optparse))

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-p", "--pam50"), action="store", default=NA, type='character',
              help="File containing PAM50 gene list"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory for output")
)

opt = parse_args(OptionParser(option_list=option_list))

PAM50.genes <- read.table(file = opt$pam50, header = T, sep = "\t", row.names = 2)
ann.data <- read.table(file = opt$target, header = T, sep = "\t")
# splitting annotation data by category (cancer, normal, unknown)
ann.data.splitted <- split(ann.data, ann.data$Target)
exp_files = unlist(strsplit(opt$exp_file, ",")) # splitting exp_file string to retrieve all the identified samples

# creating PAM50 total report dataframe (useful for updating the final target file) -- empty for now
pam50.report <- data.frame("File_name"=character(), "subtype"=character())

for (j in 1:length(exp_files)) {
  ef = paste(opt$dir,"norm_files",exp_files[j],sep = "/")
  exp.data <- read.table(file = ef, header = T, sep = "\t", stringsAsFactors = FALSE, row.names = NULL)

  ### Apply PAM50 calculations to all groups (cancer, normal, unknown), separately ###
  if (length(as.character(ann.data.splitted$cancer$File_name)) > 0) {
    selected_samples <- intersect(as.character(ann.data.splitted$cancer$File_name),colnames(exp.data))
    exp.data.category.subset <- as.data.frame(t(scale(t(data.matrix(subset(exp.data[,-1], select = selected_samples))))))
    rownames(exp.data.category.subset) = exp.data$Entrez.ID

    PAM50Preds <- calculatePam50(exp.data.category.subset, PAM50.genes)
    PAM50Preds.subtype <- data.frame("File_name"=names(PAM50Preds$subtype), "subtype"=PAM50Preds$subtype)
  }

  pam50.report <- rbind(pam50.report, PAM50Preds.subtype)
}

## writing pam50 report into file (useful for live plotting function)
pam50.report.filename = paste(opt$dir, 'pam50.report', sep = "/")
pam50.report.file = write.table(pam50.report, file = pam50.report.filename, sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

### updating target file ###
ann.data.updated <- merge(ann.data, pam50.report, by.x = "File_name", all=TRUE)
write.table(ann.data.updated, file=opt$target, sep = '\t', col.names = TRUE, row.names = FALSE, quote = FALSE, eol = '\n')
