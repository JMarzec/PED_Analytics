### bcntb.ExtractGeoDataset.R ###
### DESCRIPTION ########################################################
# This script extracts expression matrices from GEO if ArrayExpress is not working
# it is a rescue script!

### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0			2017/04/26			Stefano					this is just a rescue script!

### PARAMETERS #######################################################
current_dir <- getwd()
suppressMessages(library(GEOquery))
suppressMessages(library(optparse))

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-g", "--geo_num"), action="store", default=NA, type='character',
              help="GEO dataset number "),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))
gse <- getGEO(paste("GSE",opt$geo_num,sep = ""), GSEMatrix = TRUE)

# writing retrieved expression matrices
for (i in 1:length(gse)) {
  expr_fn = paste(opt$dir, '/',opt$geo_num,"_",i,".processed.txt",sep = "")
  write.table(exprs(gse[[i]]), file = expr_fn, quote = FALSE, row.names = TRUE, col.names = TRUE, sep = "\t")
}
