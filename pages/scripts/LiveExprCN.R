################################################################################
#
#   File name: Expr_CN_Profile.R
#
#   Authors: Jacek Marzec ( j.marzec@qmul.ac.uk )
#
#   Barts Cancer Institute,
#   Queen Mary, University of London
#   Charterhouse Square, London EC1M 6BQ
#
################################################################################

################################################################################
#
#   Description: Script generating box-plots and bar-plots to visualise expression measurments across samples and groups (as indicated in target file) from normalised expression data for user-defined gene. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: R --file=./Expr_CN_Profile.R --args "CCLE_PC_processed_mRNA.txt" "CCLE_PC_processed_CN.txt" "CCLE_target.txt" "Target" "KRAS" "Example_results/PC_Expr_CN_Profile"
#
#   First arg:      Full path with name of the normalised expression matrix
#   Second arg:     Full path with name of the relative linear copy-number matrix
#   Third arg:      Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Forth arg:      Variable from the samples annotation file to be used for samples colouring
#   Fifth arg:      ID of gene/probe of interest
#   Six arg:        Full path with name of the output folder

#
################################################################################

# silent warnings
options(warn=-1)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()

### Setting environment for pandoc
Sys.setenv(HOME = "")

#===============================================================================
#    Functions
#===============================================================================

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0

##### Assign colours to analysed groups
getTargetsColours <- function(targets) {

    ##### Predefined selection of colours for groups
   targets.colours <- c("red","blue","green","darkgoldenrod","darkred","deepskyblue", "coral", "cornflowerblue", "chartreuse4", "bisque4", "chocolate3", "cadetblue3", "darkslategrey", "lightgoldenrod4", "mediumpurple4", "orangered3","indianred1","blueviolet","darkolivegreen4","darkgoldenrod4","firebrick3","deepskyblue4", "coral3", "dodgerblue1", "chartreuse3", "bisque3", "chocolate4", "cadetblue", "darkslategray4", "lightgoldenrod3", "mediumpurple3", "orangered1")

    f.targets <- factor(targets)
    vec.targets <- targets.colours[1:length(levels(f.targets))]
    targets.colour <- rep(0,length(f.targets))
    for(i in 1:length(f.targets))
    targets.colour[i] <- vec.targets[ f.targets[i]==levels(f.targets)]

    return( list(vec.targets, targets.colour) )
}

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(plotly))
suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
              help="File containing experimental data"),
  make_option(c("-n", "--cn_file"), action="store", default=NA, type='character',
              help="File containing CN data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-c", "--colouring"), action="store", default=NA, type='character',
              help="Variable from the samples annotation file to be used for samples colouring"),
  make_option(c("-p", "--gene"), action="store", default=NA, type='character',
              help="ID of gene/probe of interest"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
cnFile <- opt$cn_file
annFile <- opt$target
target <- opt$colouring
gene <- opt$gene
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

gene = make.names(gene)

# Read file with expression data
expData <- read.table(expFile,sep="\t",as.is=TRUE,header=TRUE,row.names=NULL)

# Deal with the duplicated genes
rownames(expData) = make.names(expData$Gene.name, unique=TRUE)
expData <- expData[,-1]

# Read file with CN data
cnData <- read.table(cnFile,sep="\t",as.is=TRUE,header=TRUE,row.names=NULL)

# Deal with the duplicated genes
rownames(cnData) = make.names(cnData$Gene.name, unique=TRUE)
cnData <- cnData[,-1]


# Keep only samples present in both the expression and CN datasets
absentSamples.cnData <- colnames(expData)[colnames(expData) %!in% colnames(cnData)]
absentSamples.expData <- colnames(cnData)[colnames(cnData) %!in% colnames(expData)]

expData <- expData[,colnames(expData) %in% colnames(cnData)]
cnData <- cnData[,colnames(cnData) %in% colnames(expData)]


# Make sure that the samples order in the expression and CN matrices are the same
cnData <- cnData[, colnames(expData)]


# Retrieve the expression data file name
coreName <- strsplit(expFile, "/")
coreName <- coreName[[1]][length(coreName[[1]])]


# Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$Sample_Name <- make.names(annData$Sample_Name)


# Keep only samples with annotation info
expData <- expData[,colnames(expData) %in% annData$Sample_Name]
cnData <- cnData[,colnames(cnData) %in% annData$Sample_Name]
annData <- subset(annData, annData$Sample_Name %in% colnames(expData))
rownames(annData) <- annData$Sample_Name

# Make sure that the samples order in the data matrix and annotation file is the same
annData <- annData[colnames(expData),]

# Check if the queried genes is present in the expression data
genes <- rownames(expData)

if ( gene %!in% rownames(expData) || gene %!in% rownames(cnData) ) {
    #cat("The gene/probe", gene, "is not present in the data!", sep=" ")
    q()

# ... and extract the expression of the gene of inteterest
} else {
    gene.expr <- data.matrix(expData[gene, ])
    gene.cn <- data.matrix(cnData[gene, ])
}

# Change working directory to the project workspace
setwd(outFolder)

# # Report samples not present in the the expression or CN matrices
# if ( length(absentSamples.expData) > 0 ) {
#
#     write(absentSamples.expData, file = paste(coreName, gene, "absent_in_mRNA_data.txt", sep = "_"), append = FALSE, sep="\t",  quote=FALSE)
# }
#
# if ( length(absentSamples.cnData) > 0 ) {
#
#     write(absentSamples.cnData, file = paste(coreName, gene, "absent_in_CN_data.txt", sep = "_"), append = FALSE, sep="\t",  quote=FALSE)
# }


#===============================================================================
#     Generate mRNA expression vs DNA copy-number scatterplot
#===============================================================================

targets <- annData[,target]
targets.colour <- getTargetsColours(targets)

# Calculate Pearson correlation coefficient
expr_cn.corr <- round(
	cor.test( as.numeric(gene.expr), as.numeric(gene.cn), method = "pearson" )$estimate, digits=2
)

# Generate scatter plot (PLOTLY)
# Prepare data frame
gene.df <- data.frame(targets, as.numeric(gene.cn), as.numeric(gene.expr))
colnames(gene.df) <- c("Target", "CN", "mRNA")

p <- plot_ly(gene.df, x = ~CN, y = ~mRNA, color = ~Target, text=colnames(gene.expr), colors = targets.colour[[1]], type='scatter', mode = "markers", marker = list(size=10, symbol="circle"), width = 800, height = 600) %>%
layout(title = paste0("Pearson's r = ", expr_cn.corr), xaxis = list(title = paste0(gene, " relative linear copy-number values")), yaxis = list(title = paste0(gene, " mRNA expression")), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F, legend = list(orientation = 'v', y = 0.5), showlegend=TRUE)

# Save the box-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_mRNA_vs_CN_plot.html"), selfcontained = FALSE)


#===============================================================================
#     Calculate putative copy-number alterations
#===============================================================================

# Draw histogram of correlation coefficients (PLOTLY)
p <- plot_ly(x = ~as.numeric(gene.cn), type = 'histogram', width = 800, height = 500) %>%
layout(xaxis = list( title = paste0(gene, " relative linear copy-number values")), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)

# Save the histogram as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_corr_hist.html"), selfcontained = FALSE)


##### Assign gain and amplification for linear CN values above 0.5 and 1, respectively, and loss and deletion for linear CN values below -0.5 and -1, respectively
gene.cn[ gene.cn >= 1 ] <- 2
gene.cn[ gene.cn > 0.5 & gene.cn < 1 ] <- 1
gene.cn[ gene.cn <= -1 ] <- -2
gene.cn[ gene.cn < -0.5 & gene.cn > -1 ] <- -1
gene.cn[ gene.cn <= 0.5 & gene.cn >= -0.5 ] <- 0


#===============================================================================
#     Generate mRNA expression vs putative DNA copy-number alterations box-plot
#===============================================================================

# Preprare dataframe
gene.df <- data.frame(targets, rep(unique(targets)[1],length(targets)), as.numeric(gene.cn), as.numeric(gene.expr))
colnames(gene.df) <- c("Target", "Box", "CN", "mRNA")

gene.cn[ gene.cn == 2 ] <- "Amplification"
gene.cn[ gene.cn == 1 ] <- "Gain"
gene.cn[ gene.cn == -1 ] <- "Loss"
gene.cn[ gene.cn == -2 ] <- "Deletion"
gene.cn[ gene.cn == 0 ] <- "Diploid"

gene.df <- data.frame(targets, rep(unique(targets)[1],length(targets)), data.frame(t(gene.cn)), as.numeric(gene.expr))
colnames(gene.df) <- c("Target", "Box", "CN", "mRNA")

# Generate box-plot  (PLOTLY)
p <- plot_ly(
	gene.df,
	x = ~CN,
	y = ~mRNA,
	color = ~Target,
	colors = targets.colour[[1]],
	type='scatter',
	mode = "markers",
	marker = list(size=10, symbol="circle"),
	width = 800,
	height = 600,
	text=colnames(gene.expr)
) %>%
add_boxplot(
	gene.df, x= ~CN, y= ~mRNA, color = ~Box, key=FALSE, line = list(color = "grey"), showlegend=FALSE
) %>%
layout(
	title = "",
	xaxis = list(title = paste0(gene, " DNA copy number"), categoryarray = c("Deletion", "Loss", "Diploid", "Gain", "Amplification")),
	yaxis = list(title = paste0(gene, " mRNA expression")),
	margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F, legend = list(orientation = 'v', y = 0.5),
  showlegend=TRUE
)


# Save the box-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_mRNA_vs_CN_boxplot.html"), selfcontained = FALSE)

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
