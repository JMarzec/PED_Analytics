################################################################################
#
#   File name: Expr_CN_mut_Profile.R
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
#   Command line use example: R --file=./Expr_CN_mut_Profile.R --args "CCLE_BC_processed_mRNA.txt" "CCLE_BC_processed_CN.txt" "CCLE_BC_processed_mut.txt" "CCLE_target.txt" "ADAM28" "Example_FINAL/BC/"
#
#   First arg:      Full path with name of the normalised expression matrix
#   Second arg:     Full path with name of the relative linear copy-number matrix
#   Third arg:      Full path with name of the file with mutation data. This file is expected contain the following information: (1) sample name, (2) gene name and (3) variant classification
#   Forth arg:      Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
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

#===============================================================================
#    Functions
#===============================================================================

##### Create 'not in' operator
"%!in%" <- function(x,table) match(x,table, nomatch = 0) == 0

##### Assign colours to analysed groups
getTargetsColours <- function(targets) {

    ##### Predefined selection of colours for groups
    targets.colours <- c("red","blue","green","darkgoldenrod","darkred","deepskyblue", "coral", "cornflowerblue", "chartreuse4", "bisque4", "chocolate3", "cadetblue3", "darkslategrey", "lightgoldenrod4", "mediumpurple4", "orangered3")

    f.targets <- factor(targets)
    vec.targets <- targets.colours[1:length(levels(f.targets))]
    targets.colour <- rep(0,length(f.targets))
    for(i in 1:length(f.targets))
    targets.colour[i] <- vec.targets[ f.targets[i]==levels(f.targets)]

    return( list(vec.targets, targets.colour) )
}


##### Deal with the duplicated genes
duplGenes <- function(expData) {

    genesList <- NULL
    genesRepl <- NULL

    for ( i in 1:nrow(expData) ) {

        geneName <- expData[i,1]

        ##### Distingish duplicated genes by adding duplicate number
        if ( geneName %in% genesList ) {

            ##### Report genes with more than one duplicates
            if ( geneName %in% names(genesRepl) ) {

                genesRepl[[ geneName ]] = genesRepl[[ geneName ]]+1

                geneName <- paste(geneName, ".", genesRepl[[ geneName ]], sep="")

            } else {
                genesRepl[[ geneName ]] <- 2

                geneName <- paste(geneName, ".2", sep="")
            }
        }
        genesList <- c(genesList,geneName)
    }

    rownames(expData) <- genesList

    ##### Remove the first column with gene names, which now are used as row names
    expData <- expData[, -1]

    return(expData)
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
  make_option(c("-m", "--mut_file"), action="store", default=NA, type='character',
              help="File containing mutation data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
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
mutFile <- opt$mut_file
annFile <- opt$target
gene <- opt$gene
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

# GENE EXPRESSION
##### Read file with expression data
expData <- read.table(expFile,sep="\t",as.is=TRUE,header=TRUE,row.names=NULL)

##### Deal with the duplicated genes
expData <- duplGenes(expData)


##### Read file with CN data
cnData <- read.table(cnFile,sep="\t",as.is=TRUE,header=TRUE,row.names=NULL)

##### Deal with the duplicated genes
cnData <- duplGenes(cnData)


##### Read maf file with mutation data
mutData <- read.table(mutFile,sep="\t",as.is=TRUE,header=TRUE,row.names=NULL)


##### Keep only samples present in both the expression and CN datasets
absentSamples.cnData <- colnames(expData)[colnames(expData) %!in% colnames(cnData)]
absentSamples.expData <- colnames(cnData)[colnames(cnData) %!in% colnames(expData)]

expData <- expData[,colnames(expData) %in% colnames(cnData)]
cnData <- cnData[,colnames(cnData) %in% colnames(expData)]


##### Make sure that the samples order in the expression and CN matrices are the same
cnData <- cnData[, colnames(expData)]

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE,row.names=1)
rownames(annData) <- gsub("-", ".", rownames(annData))


##### Keep only samples with annotation info
expData <- expData[,colnames(expData) %in% rownames(annData)]
cnData <- cnData[,colnames(cnData) %in% rownames(annData)]
mutData <- mutData[mutData[,1] %in% rownames(annData), ]
annData <- subset(annData, rownames(annData) %in% colnames(expData))


##### Make sure that the samples order in the data matrix and annotation file is the same
annData <- annData[colnames(expData),]


##### Check if the queried genes is present in the expression data
genes <- rownames(expData)

if ( gene %!in% rownames(expData) ) {
    #cat("The gene/probe", gene, "is not present in the data!", sep=" ")
    q()

##### ... and extract the expression of the gene of inteterest
} else {
    gene.expr <- data.matrix(expData[gene, ])
    gene.cn <- data.matrix(cnData[gene, ])
    gene.mut <- mutData[mutData[,2]==gene, ]
}

# Change working directory to the project workspace
setwd(outFolder)


# # Report samples not present in the the expression or CN matrices
# if ( length(absentSamples.expData) > 0 ) {
#     write(absentSamples.expData, file = paste(coreName, gene, "absent_in_mRNA_data.txt", sep = "_"), append = FALSE, sep="\t")
# }
#
# if ( length(absentSamples.cnData) > 0 ) {
#     write(absentSamples.cnData, file = paste(coreName, gene, "absent_in_CN_data.txt", sep = "_"), append = FALSE, sep="\t")
# }


#===============================================================================
#     Prepare the mutation file
#===============================================================================

##### Initiate variable for the gene mutation status for each sample
gene.mut.sample <- as.matrix(rep("Not mutated", ncol(gene.expr)))
colnames(gene.mut.sample) <- "Mutation"
rownames(gene.mut.sample) <- colnames(gene.expr)


for ( i in 1:ncol(gene.expr) ) {

    if (  gene.mut[i,1] %in% colnames(gene.expr) ) {

        ##### If for a specific sample more than one mutation in the queried genes is provided then the the additional mutation categories will be also provided

        if ( gene.mut.sample[gene.mut[i,1],"Mutation"] != "Not mutated"  ) {

            gene.mut.sample[gene.mut[i,1],"Mutation"] <- paste(gene.mut.sample[gene.mut[i,1],"Mutation"], gene.mut[i,3], sep=" & ")

        } else {

            gene.mut.sample[gene.mut[i,1],"Mutation"] <- gene.mut[i,3]
        }
    }
}

#===============================================================================
#     Generate mRNA expression vs DNA copy-number scatterplot
#===============================================================================

targets <- gene.mut.sample[,"Mutation"]
targets.colour <- getTargetsColours(targets)

##### Calculate Pearson correlation coefficient
expr_cn.corr <- round(cor.test( as.numeric(gene.expr), as.numeric(gene.cn), method = "pearson" )$estimate, digits=2)

##### Generate scatter plot (PLOTLY)
##### Prepare data frame
gene.df <- data.frame(targets, as.numeric(gene.cn), as.numeric(gene.expr))
colnames(gene.df) <- c("Target", "CN", "mRNA")

p <- plot_ly(gene.df, x = ~CN, y = ~mRNA, color = ~Target, text=colnames(gene.expr), colors = targets.colour[[1]], type='scatter', mode = "markers", marker = list(size=10, symbol="circle"), width = 800, height = 600) %>%
layout(title = paste0("Pearson's r = ", expr_cn.corr), xaxis = list(title = paste0(gene, " relative linear copy-number values")), yaxis = list(title = paste0(gene, " mRNA expression")), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F, legend = list(orientation = 'v', y = 0.5), showlegend=TRUE)

##### Save the box-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_mRNA_vs_CN_mut_plot.html"))

#===============================================================================
#     Calculate putative copy-number alterations
#===============================================================================

##### Draw histogram of correlation coefficients (PLOTLY)
p <- plot_ly(x = ~as.numeric(gene.cn), type = 'histogram', width = 800, height = 500) %>%
layout(xaxis = list( title = paste0(gene, " relative linear copy-number values")), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)

##### Save the histogram as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_corr_hist.html"))


##### Assign gain for linear CN values above 0.5 and loss for linear CN values below -0.5
gene.cn[ gene.cn > 0.5 ] <- 1
gene.cn[ gene.cn < -0.5 ] <- -1
gene.cn[ gene.cn <= 0.5 & gene.cn >= -0.5 ] <- 0


#===============================================================================
#     Generate mRNA expression vs putative DNA copy-number alterations box-plot
#===============================================================================

##### Preprare dataframe
gene.df <- data.frame(targets, rep(unique(targets)[1],length(targets)), as.numeric(gene.cn), as.numeric(gene.expr))
colnames(gene.df) <- c("Target", "Box", "CN", "mRNA")

gene.cn[ gene.cn == 1 ] <- "(1) Gain"
gene.cn[ gene.cn == -1 ] <- "(-1) Loss"
gene.cn[ gene.cn == 0 ] <- "(0) Diploid"

gene.df <- data.frame(targets, rep(unique(targets)[1],length(targets)), data.frame(t(gene.cn)), as.numeric(gene.expr))
colnames(gene.df) <- c("Target", "Box", "CN", "mRNA")

##### Generate box-plot  (PLOTLY)
p <- plot_ly(gene.df, x = ~CN, y = ~mRNA, color = ~Target, colors = targets.colour[[1]], type='scatter', mode = "markers", marker = list(size=10, symbol="circle"), width = 800, height = 600, text=colnames(gene.expr) ) %>%

add_boxplot(gene.df, x= ~CN, y= ~mRNA, color = ~Box, key=FALSE, line = list(color = "grey"), showlegend=FALSE ) %>%


layout(title = "", xaxis = list(title = paste0(gene, " relative linear copy-number values")), yaxis = list(title = paste0(gene, " mRNA expression")), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F, legend = list(orientation = 'v', y = 0.5), showlegend=TRUE)


##### Save the box-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_mRNA_vs_CN_mut_boxplot.html"))

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
