################################################################################
#
#   File name: bcntb.exprCircosPlot.R
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
#   Description: Script preparing normalised expression data for generating circos plot. The pipeline performs Z-score transformation. The script retrieves gene's chromosomal positions using biomaRt R package. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: Rscript bcntb.exprCircosPlot.R --exp_file gene_exp.csv --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/ccle/norm_files
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
    make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
        help="File containing experimental data"),
    make_option(c("-d", "--dir"), action="store", default=NA, type='character',
        help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
outFolder <- opt$dir


#===============================================================================
#    Main
#===============================================================================

exp_files = unlist(strsplit(expFile, ","))


for (j in 1:length(exp_files)) {
    
    ef = paste(outFolder,exp_files[j],sep = "/")
    
    ##### Read file with expression data
    expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)
    
    ###### Deal with the duplicated genes
    expData <- duplGenes(expData)
    
    ###### Z-score transformation
    expData.z <- as.data.frame(t(scale(data.matrix(t(expData)))))
    
    ##### Generate histogram to get an idea about the relative linear copy-number values in the entire data
    p <- plot_ly(x = ~unlist(expData.z), type = 'histogram', width = 800, height = 500) %>%
    layout(xaxis = list( title = "Gene expression (Z-score)"), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)
    
    
    ##### Access Ensembl BioMart
    mart = useMart(biomart = "ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl",host = "jul2015.archive.ensembl.org")
    
    #listFilters(mart)
    #listAttributes(mart)
    
    ###### Set filters and attributes for BioMart
    theFilters = c("hgnc_symbol", "chromosome_name")
    theAttributes = c("hgnc_symbol", "chromosome_name","start_position","end_position")
    
    ###### Retrieve the gene annotation
    annot <- getBM(attributes=theAttributes,filters=theFilters,values=list(rownames(expData.z), c(1:22,"X","Y")),mart=mart)
    
    ###### remove duplicated genes
    annot <- annot[!duplicated(annot["hgnc_symbol"]),]
    
    ###### Get genes present in the data and annotation object
    annot_genes <- intersect(annot$hgnc_symbol,rownames(expData.z))
    
    expData.subset <- expData.z[rownames(expData.z) %in% annot_genes, ]
    annot <- annot[ annot$hgnc_symbol %in% annot_genes, ]
    rownames(annot) <- annot$hgnc_symbol
    annot <- annot[,-1]
    
    ##### Make sure that the genes order is the same as in the annotation object
    expData.subset <- expData.subset[ rownames(annot), ]
    
    ##### Combine the annotation and expression data
    expData.annot <- cbind(annot, expData.subset)
    
    setwd(outFolder)
    
    ##### Save the histogram as html (PLOTLY)
    htmlwidgets::saveWidget(as_widget(p), paste0(expFile, "_annotated_hist_",j,".html"))
    
    ##### Write the annotated expression data into a file
    write.table(prepare2write(expData.annot), file=paste0(expFile, "_annotated.csv"), sep="\t", row.names=FALSE)
}

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
