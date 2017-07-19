################################################################################
#
#   File name: LiveCNAlterations.R
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
#   Description: Script performing principal component analysis using normalised expression data. It generates 3-dimensional plot of user-defined principal component and two . NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: Rscript LiveCNAlterations.R --cn_file cn_chr_pos.csv --target cn_target.txt --genes KRAS,TP53,SMAD4,CDKN2A --colouring Target --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics_backup/ped_backoffice/data/ccle --hexcode fdshf
#
#   First arg:      Full path with name of the copy-number data
#   Second arg:     Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Third arg:      IDs of genes/probe of interest
#   Forth arg:      Variable from the samples annotation file to be used for samples colouring
#   Fifth arg:      Unique ID to save temporary plots
#
################################################################################

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

                geneName <- paste(geneName, "-", genesRepl[[ geneName ]], sep="")

            } else {
                genesRepl[[ geneName ]] <- 2

                geneName <- paste(geneName, "-2", sep="")
            }
        }
        genesList <- c(genesList,geneName)
    }

    rownames(expData) <- genesList

    ##### Remove the first column with gene names, which now are used as row names
    expData <- expData[, -1]

    return(expData)
}


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


#===============================================================================
#    Load libraries
#===============================================================================
suppressMessages(library(plotly))
suppressMessages(library(heatmaply))
suppressMessages(library(optparse))


#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
    make_option(c("-e", "--cn_file"), action="store", default=NA, type='character',
        help="File containing experimental data"),
    make_option(c("-t", "--target"), action="store", default=NA, type='character',
        help="Clinical data saved in tab-delimited format"),
    make_option(c("-p", "--genes"), action="store", default=NA, type='character',
        help="ID of genes/probe of interest"),
    make_option(c("-c", "--colouring"), action="store", default=NA, type='character',
        help="Variable from the samples annotation file to be used for samples colouring"),
    make_option(c("-d", "--dir"), action="store", default=NA, type='character',
        help="Default directory"),
    make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
        help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

cnFile <- opt$cn_file
annFile <- opt$target
gene_list <- opt$genes
target <- opt$colouring
outFolder <- opt$dir
hexcode <- opt$hexcode


#===============================================================================
#    Main
#===============================================================================

cn_files = unlist(strsplit(cnFile, ","))

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$Sample_Name <- make.names(annData$Sample_Name)

##### Read gene list
genes = unlist(strsplit(gene_list, ","))

for (j in 1:length(cn_files)) {

    #ef = paste(outFolder,"norm_files",cn_files[j],sep = "/")
    ef = cn_files[j]
    
    ##### Read file with copy-number data
    cnData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

    ###### Deal with the duplicated genes
    cnData <- duplGenes(cnData)

    ###### Keep only the copy-number data
    cnData <- cnData[, c(3:ncol(cnData))]

    ###### Check samples present in current dataset
    selected_samples <- intersect(as.character(annData$Sample_Name),colnames(cnData))
    cnData.subset <- cnData[,colnames(cnData) %in% selected_samples]
    
    ##### Make sure that the sample order is the same as in the target file
    cnData.subset <- cnData.subset[ , selected_samples ]

    targets <- subset(annData, Sample_Name %in% colnames(cnData.subset))[,target]
    
    ##### This plot is not necessary, it's only to get an idea about the relative linear copy-number values in the entire data #####
    ##### Draw histogram of correlation coefficients (PLOTLY)
    #p <- plot_ly(x = ~unlist(cnData.subset), type = 'histogram', width = 800, height = 500) %>%
    #layout(xaxis = list( title = "Relative linear copy-number values"), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)
    #
    ##### Save the histogram as html (PLOTLY)
    #htmlwidgets::saveWidget(as_widget(p), paste0(hexcode,"cn_hist_",j,".html"))
    
    ##### Keep only genes of interest
    cnData.subset <- cnData.subset[genes, ]
    
    ##### Identify genes of interest not present in the expression matrix
    absentGenes <- genes[genes %!in% rownames(cnData.subset)]
    
    ##### Change working directory to the project workspace
    setwd(outFolder)
    
    #===============================================================================
    #    Generate heatmap to examine differences across all samples
    #===============================================================================

    ##### Assign gain for linear CN values above 0.5 and loss for linear CN values below -0.5
    cnData.subset[ cnData.subset > 0.5 ] <- 1
    cnData.subset[ cnData.subset < -0.5 ] <- -1
    cnData.subset[ cnData.subset <= 0.5 & cnData.subset >= -0.5 ] <- 0

    ##### Set the heatmap hight based on the number of queried genes
    if ( length(genes) > 2 ) {
        hheight <- length(genes)*100
    } else {
        hheight <- 300
    }
    ##### Cluster samples
    hc <- hclust(as.dist(dist(data.frame(t(cnData.subset)), method="euclidean")), method="ward.D")
    
    ##### Generate heatmap (PLOTLY)
    p <- heatmaply(data.frame(cnData.subset ), Rowv=NULL, Colv=as.dendrogram(hc), colors = c("blue", "white", "red"), scale="none", trace="none", hide_colorbar = TRUE, fontsize_row = 8, fontsize_col = 8, showticklabels=c(TRUE, TRUE)) %>%
    layout(autosize = FALSE, width = 800, height = hheight,  margin = list(l=100, r=50, b=150, t=50, pad=4), showlegend = FALSE)

    ##### Save the heatmap as html (PLOTLY)
    widget_fn = paste0(hexcode,"_heatmap_",j,".html")
    htmlwidgets::saveWidget(p, widget_fn)

    ##### Close any open graphics devices
    graphics.off()
}
