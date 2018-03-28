################################################################################
#
#   File name: bcntb.cnCircosPlot.binary.perGroup.R
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
#   Description: Script preparing binarised copy-number values data for generating circos plot. The pipeline rounds the copy-number information FOR EACH GROUP. The script retrieves gene's chromosomal positions using biomaRt R package. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: Rscript bcntb.cnCircosPlot.binary.perGroup.R --cn_file cn_binary.csv  --target cn_target.txt --colouring Target --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/tcga
#
#   First arg:      Full path with name of the normalised copy-number data
#   Second arg:     Full path with name of the output folder
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


##### Prepare object to write into a file
prepare2write <- function (x) {

    x2write <- cbind(rownames(x), x)
    colnames(x2write) <- c("",colnames(x))
    return(x2write)
}

##### Decide which copy-number status to assign for each gene
decide.cn.status <- function (x) {

  x <- as.numeric(x)

  ##### assign status different then '0' only to genes with at least 70% of samples with some copy-number alteration
  if ( table(x)[ names(table(x))==0 ]/length(x) < 0.7  ) {

    ##### Select the most frequent alteration
    cn.status <- names(sort(table(x)[ !(names(table(x))==0)], decreasing = TRUE))[1]

  } else {
    cn.status <- "0"
  }

  return(cn.status)
}

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(plotly))
suppressMessages(library(Biobase))
suppressMessages(library(optparse))
suppressMessages(library(biomaRt))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
    make_option(c("-e", "--cn_file"), action="store", default=NA, type='character',
        help="File containing experimental data"),
    make_option(c("-t", "--target"), action="store", default=NA, type='character',
        help="Clinical data saved in tab-delimited format"),
    make_option(c("-c", "--colouring"), action="store", default=NA, type='character',
        help="Variable from the samples annotation file to be used for samples colouring"),
    make_option(c("-d", "--dir"), action="store", default=NA, type='character',
        help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

cnFile <- opt$cn_file
annFile <- opt$target
target <- opt$colouring
outFolder <- opt$dir


#===============================================================================
#    Main
#===============================================================================

cn_files = unlist(strsplit(cnFile, ","))

##### Read sample annotation file
annData <- read.table( paste(outFolder,annFile,sep = "/"),sep="\t",as.is=TRUE,header=TRUE)
annData$Sample_Name <- make.names(annData$Sample_Name)

for (j in 1:length(cn_files)) {

    ef = paste(outFolder,"norm_files",cn_files[j],sep = "/")

    ##### Read file with copy-number data
    cnData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

    ###### Deal with the duplicated genes
    rownames(cnData) = make.names(cnData$Gene.name, unique=TRUE)
    cnData <- cnData[,-1]

    ###### Check samples present in current dataset
    selected_samples <- intersect(as.character(annData$Sample_Name),colnames(cnData))
    cnData.subset <- cnData[,colnames(cnData) %in% selected_samples]

    ##### Make sure that the sample order is the same as in the target file
    cnData.subset <- cnData.subset[ , selected_samples ]

    targets <- subset(annData, Sample_Name %in% colnames(cnData.subset))[,target]

    ##### Access Ensembl BioMart
    mart = useMart(biomart = "ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl",host = "jul2015.archive.ensembl.org")

    #listFilters(mart)
    #listAttributes(mart)

    ###### Set filters and attributes for BioMart
    theFilters = c("hgnc_symbol", "chromosome_name")
    theAttributes = c("hgnc_symbol", "chromosome_name","start_position","end_position")

    ###### Retrieve the gene annotation
    annot <- getBM(attributes=theAttributes,filters=theFilters,values=list(rownames(cnData.subset), c(1:22,"X","Y")),mart=mart)

    ###### remove duplicated genes
    annot <- annot[!duplicated(annot["hgnc_symbol"]),]

    ###### Get genes present in the data and annotation object
    annot_genes <- intersect(annot$hgnc_symbol,rownames(cnData.subset))

    cnData.subset <- cnData.subset[rownames(cnData.subset) %in% annot_genes, ]
    annot <- annot[ annot$hgnc_symbol %in% annot_genes, ]
    rownames(annot) <- annot$hgnc_symbol
    annot <- annot[,-1]

    ##### Make sure that the genes order is the same as in the annotation object
    cnData.subset <- cnData.subset[ rownames(annot), ]

    ##### Calculate the per-gene copy-number for each group
    cnData.subset.status <- annot

    for (i in 1:length(unique(targets))) {

        ##### Select samples from the group
        target.sel <- unique(targets, decreasing = TRUE)[i]

        cnData.subset.sel <- cnData.subset[ ,targets %in%  unique(targets)[i] ]

        ##### Decide which copy-number status to assign for each gene
        cnData.subset.sel.status <- as.data.frame(apply(cnData.subset.sel, 1, decide.cn.status))
        colnames(cnData.subset.sel.status) <- target.sel

        ##### Create gene-annotated matrix with PER-GROUP copy-number status
        cnData.subset.status <- cbind(cnData.subset.status, cnData.subset.sel.status)
    }

    ##### Generate histogram to get an idea about the frequency copy-number status across ALL GROUPS
    p <- plot_ly(x = ~unlist(cnData.subset.status[,-c(1:3)]), type = 'histogram', width = 800, height = 500) %>%
    layout(xaxis = list( title = "Per-gene copy-number values across groups"), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)

    ##### Save the histogram as html (PLOTLY)
    htmlwidgets::saveWidget(as_widget(p), paste0(outFolder,"/norm_files/", cnFile, "_perGroup_annotated_hist_",j,".html"), selfcontained = FALSE)

    setwd(outFolder)

    ##### Write the annotated copy-number data into a file
    write.table(prepare2write(cnData.subset.status), file=paste0("norm_files/", cnFile, "_perGroup_annotated_",j,".csv"), sep="\t", row.names=FALSE,  quote=FALSE)
}

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
