### HISTORY ##############################################################################
# Version			Date					Coder						Comments
# 1.0 				13/07/2017				Ema & Stefano
#
#   Contact: Emanuela, Jacek, Stefano (e.gadaleta@qmul.ac.uk; s.pirro@qmul.ac.uk)
#
#   Barts Cancer Institute
#   Queen Mary, University of London
#   Charterhouse Square, London EC1M 6BQ
#
### DESCRIPTION ##########################################################################
#  Read in the mutation and clinical data downloaded previously from TCGA and plot top/defined mutations
## https://cancergenome.nih.gov/; https://ocg.cancer.gov/programs/target/research
## http://bioconductor.org/packages/release/bioc/vignettes/TCGAbiolinks/inst/doc/tcgaBiolinks.html


#========================================================================================#
# Clear workspace
rm(list=ls());
# Close any open graphics devices
graphics.off();

#========================================================================================#
#    									FUNCTIONS										 #
#========================================================================================#


#========================================================================================#
#    						INSTALL AND LOAD LIBRARIES									 #
#========================================================================================#
# install libraries if not present
#TCGA.libs <- c("TCGAbiolinks","SummarizedExperiment");

#if (length(setdiff(TCGA.libs, rownames(installed.packages()))) > 0) {
#   source("http://bioconductor.org/biocLite.R")
#   biocLite(setdiff(TCGA.libs, rownames(installed.packages())))
#}

# load libraries
#library("TCGAbiolinks");
#library("SummarizedExperiment");

suppressMessages(library(TCGAbiolinks))
suppressMessages(library(SummarizedExperiment))
suppressMessages(library(optparse))


#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-e", "--mut_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-p", "--gene"), action="store", default=NA, type='character',
              help="ID of genes/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

mutFile <- opt$exp_file
annFile <- opt$target
gene <- opt$gene
outFolder <- opt$dir
hexcode <- opt$hexcode


#========================================================================================#
#    										MAIN						  				 #
#========================================================================================#
#args <- commandArgs();

#args[4]<-"TCGA.BRCA.mutect_update.txt";
#args[5]<-"mut_target.txt";
#args[6]<-"Testing/";

#mutFile <- args[4];
#annFile <- args[5];
#outFolder <- args[6];
#gene_list <- c("BRCA1", "BRCA2", "ERBB2", "S100P", "AURKA", "TP53");

#========================================================================================#
# COLLECTION OF INFORMATION: CLINICAL, MUTATION AND GENES
annData <- read.table(file = annFile, row.names = 1, header = T, sep = "\t");
mutData <- read.table(file = mutFile, row.names = NULL, header = T, sep = "\t");

# isolate genes, split by comma
genes = unlist(strsplit(gene_list, ","));


# SET THE WORKING DIRECTORY TO THE WORKSPACE
setwd(outFolder);

#========================================================================================#
#    							PREPARE DATA INPUTS										 #
#========================================================================================#
# DEFINE PLOTTING PARAMETERS
# subset mutation data to user-defined genes
mutData.user <- subset(mutData, Hugo_Symbol %in% genes);
mutData.user <- mutData[rownames(mutData.user),];

# count the number of times the genes are mutated
mutCount <- as.data.frame(table(mutData.user$Hugo_Symbol));
mutCount <- mutCount[ order(mutCount$Freq, decreasing=TRUE ),];

# Subset clinical data to display pre-defined covariates
annCovar <- c("bcr_patient_barcode", "surv.stat", "gender", "subtype",  "stage_category");
annData.top <- annData[ , annCovar ];


# GENERATE ONCOPRINT
TCGAvisualize_oncoprint(
	mut = mutData.user,
	genes = genes,
	filename = paste0(hexcode, "_mutations_user_genes.pdf", sep=""),
	annotation = annData.top,
	color=c("background"="#CCCCCC","DEL"="purple", "INS"="yellow","SNP"="brown"),
	rows.font.size= 3,
	width = 5,
	heatmap.legend.side = "right",
	dist.col = 0,
	label.font.size = 3
);
