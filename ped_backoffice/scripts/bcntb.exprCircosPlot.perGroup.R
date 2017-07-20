################################################################################
#
#   File name: bcntb.exprCircosPlot.perGroup.R
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
#   Description: Script preparing normalised expression data for generating circos plot. The pipeline performs Z-score transformation and calculates median values of Z-scores for each group. The script retrieves gene's chromosomal positions using biomaRt R package. NOTE: the script allowes to process gene matrix with duplicated gene IDs.
#
#   Command line use example: Rscript bcntb.exprCircosPlot.perGroup.R --exp_file gene_exp.csv --target cn_target.txt --colouring Target --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/ccle
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
suppressMessages(library(Biobase))
suppressMessages(library(optparse))
suppressMessages(library(biomaRt))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
    make_option(c("-e", "--exp_file"), action="store", default=NA, type='character',
        help="File containing experimental data"),
    make_option(c("-t", "--target"), action="store", default=NA, type='character',
        help="Clinical data saved in tab-delimited format"),
    make_option(c("-c", "--colouring"), action="store", default=NA, type='character',
        help="Variable from the samples annotation file to be used for samples colouring"),
    make_option(c("-d", "--dir"), action="store", default=NA, type='character',
        help="Default directory")
)

opt = parse_args(OptionParser(option_list=option_list))

expFile <- opt$exp_file
annFile <- opt$target
target <- opt$colouring
outFolder <- opt$dir


#===============================================================================
#    Main
#===============================================================================

exp_files = unlist(strsplit(expFile, ","))

##### Read sample annotation file
annData <- read.table( paste(outFolder,annFile,sep = "/"),sep="\t",as.is=TRUE,header=TRUE)
annData$File_name <- make.names(annData$File_name)

for (j in 1:length(exp_files)) {
    
    ef = paste(outFolder,"norm_files",exp_files[j],sep = "/")
    
    ##### Read file with expression data
    expData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)
    
    ###### Deal with the duplicated genes
    expData <- duplGenes(expData)
    
    
    ###### Check samples present in current dataset
    selected_samples <- intersect(as.character(annData$File_name),colnames(expData))
    expData.subset <- expData[,colnames(expData) %in% selected_samples]
    
    ##### Make sure that the sample order is the same as in the target file
    expData.subset <- expData.subset[ , selected_samples ]
    
    targets <- subset(annData, File_name %in% colnames(expData.subset))[,target]
    
    
    ##### Perfrom Z-score transformation
    expData.z <- as.data.frame(t(scale(data.matrix(t(expData.subset)))))
    
    ##### Generate histogram to get an idea about the relative linear copy-number values in the entire data
    p <- plot_ly(x = ~unlist(expData.z), type = 'histogram', width = 800, height = 500) %>%
    layout(xaxis = list( title = "Gene expression (Z-score)"), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)
    
    ##### Save the histogram as html (PLOTLY)
    htmlwidgets::saveWidget(as_widget(p), paste0(outFolder,"/norm_files/", expFile, "_perGroup_annotated_hist_",j,".html"))
    
    
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
    
    expData.z <- expData.z[rownames(expData.z) %in% annot_genes, ]
    annot <- annot[ annot$hgnc_symbol %in% annot_genes, ]
    rownames(annot) <- annot$hgnc_symbol
    annot <- annot[,-1]
    
    ##### Make sure that the genes order is the same as in the annotation object
    expData.z <- expData.z[ rownames(annot), ]
    
    
    ##### Calculate the per-gene median for each group
    expData.z.median <- annot
    

    for (i in 1:length(unique(targets))) {
        
        ##### Select samples from the group
        target.sel <- unique(sort(targets, decreasing = TRUE))[i]
        
        expData.z.sel <- expData.z[ targets %in%  target.sel ]
        
        ##### Calculate the per-gene median for each group
        expData.z.sel.median <- as.data.frame(rowMedians(data.matrix(expData.z.sel)))
        rownames(expData.z.sel.median) <- rownames(expData.z.sel.median)
        colnames(expData.z.sel.median) <- target.sel
        
        ##### Create gene-annotated matrix with Z-score median values for each group
        expData.z.median <- cbind(expData.z.median, expData.z.sel.median)
    }
    
    setwd(outFolder)
    
    ##### Write the annotated expression data into a file
    write.table(prepare2write(expData.z.median), file=paste0("norm_files/", expFile, "_perGroup_annotated_",j,".csv"), sep="\t", row.names=FALSE)
}

##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
