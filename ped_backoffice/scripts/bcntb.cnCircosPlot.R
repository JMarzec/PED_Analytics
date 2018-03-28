################################################################################
#
#   File name: bcntb.cnCircosPlot.R
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
#   Description: Script preparing relative linear copy-number values data for generating circos plot. The script retrieves gene's chromosomal positions using biomaRt R package. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: Rscript bcntb.cnCircosPlot.R --cn_file cn.csv --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/ccle
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

#===============================================================================
#    Load libraries
#===============================================================================

suppressMessages(library(plotly))
suppressMessages(library(optparse))
suppressMessages(library(biomaRt))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
    make_option(c("-e", "--cn_file"), action="store", default=NA, type='character',
        help="File containing experimental data"),
    make_option(c("-d", "--dir"), action="store", default=NA, type='character',
        help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

cnFile <- opt$cn_file
outFolder <- opt$dir


#===============================================================================
#    Main
#===============================================================================

cn_files = unlist(strsplit(cnFile, ","))


for (j in 1:length(cn_files)) {

    ef = paste(outFolder,"norm_files",cn_files[j],sep = "/")

    ##### Read file with copy-number data
    cnData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)

    ###### Deal with the duplicated genes
    rownames(cnData) = make.names(cnData$Gene.name, unique=TRUE)
    cnData <- cnData[,-1]

    ##### Generate histogram to get an idea about the relative linear copy-number values in the entire data
    p <- plot_ly(x = ~unlist(cnData), type = 'histogram', width = 800, height = 500) %>%
    layout(xaxis = list( title = "Relative linear copy-number values"), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)


    ##### Assign gain for linear CN values above 0.5 and loss for linear CN values below -0.5
    #cnData[ cnData > 0.5 ] <- 1
    #cnData[ cnData < -0.5 ] <- -1
    #cnData[ cnData <= 0.5 & cnData >= -0.5 ] <- 0


    ##### Access Ensembl BioMart
    mart = useMart(biomart = "ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl",host = "jul2015.archive.ensembl.org")

    #listFilters(mart)
    #listAttributes(mart)

    ###### Set filters and attributes for BioMart
    theFilters = c("hgnc_symbol", "chromosome_name")
    theAttributes = c("hgnc_symbol", "chromosome_name","start_position","end_position")

    ###### Retrieve the gene annotation
    annot <- getBM(attributes=theAttributes,filters=theFilters,values=list(rownames(cnData), c(1:22,"X","Y")),mart=mart)

    ###### remove duplicated genes
    annot <- annot[!duplicated(annot["hgnc_symbol"]),]

    ###### Get genes present in the data and annotation object
    annot_genes <- intersect(annot$hgnc_symbol,rownames(cnData))

    cnData.subset <- cnData[rownames(cnData) %in% annot_genes, ]
    annot <- annot[ annot$hgnc_symbol %in% annot_genes, ]
    rownames(annot) <- annot$hgnc_symbol
    annot <- annot[,-1]

    ##### Make sure that the genes order is the same as in the annotation object
    cnData.subset <- cnData.subset[ rownames(annot), ]

    ##### Combine the annotation and copy-number data
    cnData.annot <- cbind(annot, cnData.subset)

    setwd(outFolder)

    ##### Save the histogram as html (PLOTLY)
    htmlwidgets::saveWidget(as_widget(p), paste0(outFolder,"/norm_files/", cnFile, "_annotated_hist_",j,".html"), selfcontained = FALSE)

    ##### Write the annotated copy-number data into a file
    write.table(prepare2write(cnData.annot), file=paste0("norm_files/", cnFile, "_annotated_",j,".csv"), sep="\t", row.names=FALSE,  quote=FALSE)
}

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
