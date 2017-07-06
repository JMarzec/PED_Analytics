### bcntb.mclust.R ###
### DESCRIPTION ########################################################
# This script assigns ER, PR and Her2 status to samples based on their expression values
# and identifies triple negative samples

### HISTORY ###########################################################
# Version		Date					Coder						Comments
# 1.0			2017/04/18			Stefano					optimized from 'bcntb.apply.mclust.eg.R' Emanuela's version

### PARAMETERS #######################################################
current_dir <- getwd()
suppressMessages(source(paste(current_dir,"scripts/bcntb.functions.R",sep = "/")))
suppressMessages(library(optparse))
suppressMessages(library(mclust))

##### COMMAND LINE PARAMETERS ###############################################
### Here we take advantage of Optparse to manage arguments####
### Creating list of arguments ###
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory for output")
)

opt = parse_args(OptionParser(option_list=option_list))

# loading sources
ann.data <- read.table(file = opt$target, header = T, sep = "\t")
# splitting annotation data by category (cancer, normal, unknown)
ann.data.splitted <- split(ann.data, ann.data$Target)
exp_files = unlist(strsplit(opt$exp_file, ",")) # splitting exp_file string to retrieve all the identified samples

# listing receptor genes
# ENSG00000091831,  = ESR1 -- Entrez = 2099
# ENSG00000082175 = PGR -- Entrez = 5241
# ENSG00000141736 = ERBB2 -- Entrez = 2064
receptor.genes = c('2099','5241','2064')

# creating mclust total report dataframe (useful for updating the final target file) -- empty for now
mclust.final.report <- as.data.frame(matrix(NA, ncol = 4, nrow = 0))

for (j in 1:length(exp_files)) {
    ef = paste(opt$dir,"norm_files",exp_files[j],sep = "/")
    #print(ef)

    exp.data <- read.table(file = ef, header = T, sep = "\t", stringsAsFactors = FALSE, row.names = NULL)

    ### Apply MCLUST calculations to cancer group ###
    # creating mclust tmp report dataframe (useful for updating the final target file) -- empty for now
    mclust.tmp.report <- data.frame("File_name"=ann.data$File_name)

    # create empty lists for er/pr/her2 + & - sample names
    neg.data <- data.frame("File_name"=character(), "mclust"=character());
    pos.data <- data.frame("File_name"=character(), "mclust"=character());

    # loading expression data based on category (cancer, normal, unknown)
    if (length(as.character(ann.data.splitted$cancer$File_name)) > 0) {
      selected_samples <- intersect(as.character(ann.data.splitted$cancer$File_name),colnames(exp.data))
      exp.data.category.subset <- as.data.frame(t(scale(t(data.matrix(subset(exp.data[,-1], select = selected_samples))))))
      rownames(exp.data.category.subset) = exp.data$Entrez.ID

      # implement MCLUST to a +'ve or -'ve receptor status to each sample
      # where G=2  i.e. 2-component Gaussian mix
      for( rgene in receptor.genes ) {
        if (!is.na(exp.data.category.subset[rgene , ])) {
            optimal.model <- Mclust(
              data = exp.data.category.subset[rgene , ],
              G = 2,
              prior = NULL,
              control = emControl(),
              initialization = NULL,
              warn = FALSE
            );

            # assign sample names into -'ve (grp.1) & +'ve (grp.2) groups
            grp.1 <- names( which(optimal.model$classification == 1) );
            grp.2 <- names( which(optimal.model$classification == 2) );
            #print(summary(optimal.model));

            # assign the -'ve & +'ve sample names for each EnsemblGene to list
            neg.data <- data.frame('File_name'=grp.1,'status'=rep('0',length(grp.1)));
            colnames(neg.data)[2] = rgene
            pos.data <- data.frame('File_name'=grp.2,'status'=rep('1',length(grp.2)));
            colnames(pos.data)[2] = rgene

            ### updating mclust total report target file ###
            mclust.tmp.report <- merge(mclust.tmp.report, rbind(neg.data,pos.data), by.x = 'File_name')
        } else {
            na.data <- data.frame('File_name'=ann.data$File_name,'status'=rep(NA,length(ann.data$File_name)));
            colnames(na.data)[2] = rgene
            mclust.tmp.report <- merge(mclust.tmp.report, na.data, by.x = 'File_name')
        }
      }
    }
    mclust.final.report <- rbind(mclust.final.report,mclust.tmp.report)
}
mclust.final.report <- mclust.final.report[!duplicated(mclust.final.report[,1]),]

# id TN sample names from list by identifying er, pr and her2 negative samples
mrna.na <- mclust.final.report[which(is.na(mclust.final.report[,2]) | is.na(mclust.final.report[,3]) | is.na(mclust.final.report[,4])),];
mrna.tn <- mclust.final.report[which(mclust.final.report[,2]==0 & mclust.final.report[,3]==0 & mclust.final.report[,4]==0),];
mrna.non.tn <- mclust.final.report[ !(mclust.final.report$File_name %in% rbind(mrna.na,mrna.tn)$File_name), ]

# all TNs with assignment of TN to "1", "0" otherwise
if (nrow(mrna.na) > 0) {
    mrna.na$tn_status = NA
}
if (nrow(mrna.tn) > 0) {
    mrna.tn$tn_status = 1
}
if (nrow(mrna.non.tn) > 0) {
    mrna.non.tn$tn_status = 0
}

# updating final report
mclust.final.report = merge(mclust.final.report, rbind(mrna.tn,mrna.non.tn,mrna.na))
# as colnames for the final report, we report the gene names as labels
colnames(mclust.final.report) = c('File_name','ER','PGR','HER2','tn_status')

## writing mclust report into file (useful for live plotting function)
  #### initialising the filename and directory where to save the report
  mclust.report.filename = paste(opt$dir, 'mclust.report', sep = "/")
  #### creating structure for the report and filling information ####
  mclust.report <- data.frame(row.names = c("Neg", "Pos"), ER = numeric(2), PGR=numeric(2), HER2=numeric(2), TripleNegative=numeric(2))
  #### Counting samples with Positive or Negative status for each receptor (and also Triple Negative)
  ER_report <- table(mclust.final.report$ER)
  PGR_report <- table(mclust.final.report$PGR)
  HER2_report <- table(mclust.final.report$HER2)
  TN_report <- table(mclust.final.report$tn_status)
  #### Filling mclust report
  mclust.report$ER <- ER_report
  mclust.report$PGR <- PGR_report
  mclust.report$HER2 <- HER2_report
  mclust.report$TripleNegative <- TN_report
  #### writing mclust into file
  mclust.report.file = write.table(mclust.report, file = mclust.report.filename, sep = "\t", row.names = TRUE, col.names = TRUE, quote = FALSE)
## ---------------------------------------------------------------------- ##

# updating target file
ann.data.updated <- merge(ann.data, mclust.final.report, by.x = "File_name", all=TRUE)
#print(ann.data.updated)
write.table(ann.data.updated, file=opt$target, sep = '\t', col.names = TRUE, row.names = FALSE, quote = FALSE, eol = '\n')
