################################################################################
#
#   File name: bcntb.cnFrequencyPerGene.R
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
#   Command line use example: Rscript bcntb.cnFrequencyPerGene.R --cn_file cn_chr_pos_noXY.csv --target cn_target.txt --colouring Target --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics_backup/ped_backoffice/data/ccle
#
#   First arg:      Full path with name of the normalised expression matrix
#   Second arg:     Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Third arg:      Variable from the samples annotation file to be used for samples colouring
#   Forth arg:      The principal component to be plotted together with the two subsequent most prevalent principal components
#   Fifth arg:      Full path with name of the output folder
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
annData <- read.table(paste(outFolder,annFile,sep = "/"),sep="\t",as.is=TRUE,header=TRUE)


for (j in 1:length(cn_files)) {
    
    ef = paste(outFolder,"norm_files",cn_files[j],sep = "/")
    
    ##### Read file with copy-number data
    cnData <- read.table(ef,sep="\t",header=TRUE,row.names=NULL, stringsAsFactors = FALSE)
    
    ###### Deal with the duplicated genes
    cnData <- duplGenes(cnData)
    
    ######  Keep genomic info separately
    cnData.pos <- cnData[, c(1:3)]
    cnData <- cnData[, c(3:ncol(cnData))]
    
    ###### Check samples present in current dataset
    selected_samples <- intersect(as.character(annData$Sample_Name),colnames(cnData))
    cnData.subset <- cnData[,colnames(cnData) %in% selected_samples]
    
    ##### Make sure that the sample order is the same as in the target file
    cnData.subset <- cnData.subset[ , selected_samples ]
    
    targets <- subset(annData, Sample_Name %in% colnames(cnData.subset))[,target]
    
    ##### This plot is not necessary, it's only to get an idea about the relative linear copy-number values #####
    ##### Draw histogram of correlation coefficients (PLOTLY)
    #p <- plot_ly(x = ~unlist(cnData.subset), type = 'histogram', width = 800, height = 500) %>%
    #layout(xaxis = list( title = "Relative linear copy-number values"), yaxis = list( title = "Frequency"), margin = list(l=50, r=50, b=50, t=50, pad=4), autosize = F)
    #
    ##### Save the histogram as html (PLOTLY)
    #htmlwidgets::saveWidget(as_widget(p), "cn_hist.html")
    
    #===============================================================================
    #    Generate frequency plot for each group separately
    #===============================================================================
    
    for(i in 1:length(unique(targets))) {
        
        ##### Select samples from the group
        target.sel <- unique(sort(targets, decreasing = TRUE))[i]
        
        cnData.subset.sel <- cnData.subset[ targets %in%  target.sel    ]
        
        ##### Add genomic info
        cnData.subset.sel <- cbind(cnData.pos, cnData.subset.sel)
        
        cnData.subset.sel$Loss=rep(0,length(nrow(cnData.subset.sel)))
        cnData.subset.sel$Gain=rep(0,length(nrow(cnData.subset.sel)))
        
        ##### Order the data accordingly to genomic postions
        cnData.subset.sel = cnData.subset.sel[order(as.numeric(cnData.subset.sel$Chromosome),as.numeric(cnData.subset.sel$Position)),]
        
        ##### Count number of samples with gains/losses at each position (segment mean > 0.5 or <= -05, respectively)
        gainSum <- rowSums(cnData.subset.sel[,c(3:ncol(cnData.subset.sel))] > 0.5)/(ncol(cnData.subset.sel)-4)
        lossSum <- rowSums(cnData.subset.sel[,c(3:ncol(cnData.subset.sel))] <= -0.5)/(ncol(cnData.subset.sel)-4)
        
        ##### Get frequency values
        cnData.subset.sel[,"Gain"] = gainSum
        cnData.subset.sel[,"Loss"] = -lossSum
        
        ##### Label chromosomes
        chr_bins <- data.matrix(summary(as.factor(cnData.subset.sel$Chromosome)))
        chr_bins<- data.frame(chr_bins,row.names(chr_bins) )
        colnames(chr_bins) = c("count","Chromosome")
        
        data.chr_bins <- data.frame(unique(cnData.subset.sel$Chromosome))
        colnames(data.chr_bins) = c("Chromosome")
        
        chr_annot <- merge(data.chr_bins,chr_bins, by.x="Chromosome", by.y="Chromosome", sort=FALSE)
        
        for(k in 2:length(row.names(chr_annot))) {
            
            chr_annot[k,2] = chr_annot[k-1,2] + chr_annot[k,2]
        }
        
        chr_annot[1,3] <- chr_annot[1,2] / 2
        
        for (k in 2:length(row.names(chr_annot))) {
            
            chr_annot[k,3] <- (chr_annot[k,2]+chr_annot[k-1,2])/2
        }
        
        ##### Create a list with chromosme boundaries info
        chr_nos <- list( x = chr_annot[, 3], y = -1.1, text = chr_annot$Chromosome, xref = "x", yref = "y", showarrow = FALSE )
        
        ##### Prepare vector to indicate chromosome boundaries
        chr_lines <- rep(0, nrow(cnData.subset.sel))
        chr_lines[ chr_annot[,2]-1 ] <- 1
        chr_lines[ chr_annot[,2] ] <- -1
        
        #####
        data2plot <- data.frame(rownames(cnData.subset.sel), cnData.subset.sel$Loss, cnData.subset.sel$Gain, chr_lines)
        
        colnames(data2plot) <- c("Gene", "Loss", "Gain", "Chr_line")
        
        ##### Use the genomic positions order for bars
        data2plot$Gene <- factor(data2plot$Gene, levels = data2plot$Gene)
        
        
        p <- plot_ly(data2plot, x = ~Gene, y = ~Gain, type = 'bar', name = "Gain", color = I("red"), width = 800, height = 400) %>%
        add_trace(y = ~Loss, name = "Loss", color = I("blue")) %>%
        add_trace(x = ~Gene, y = ~Chr_line, type = 'scatter', name = "Chromosomes", mode = 'lines', line = list(color = "lightgrey", dash = "1px"), hoverinfo = "skip") %>%
        layout( title = target.sel, yaxis = list(title = "Fraction of samples"), xaxis = list(title = "Chromosome number", showticklabels = FALSE), annotations = chr_nos, barmode = 'group', bargap = 0, margin = list(l=50, r=50, b=100, t=50, pad=4), autosize = F, legend = list(orientation = 'h', y = 1.07, tracegroupgap=0), showlegend=TRUE)
        
        ##### Save the frequency plot as html (PLOTLY)
        widget_fn = paste(outFolder,paste0("frequency_plot_",j,"_",i,".html"),sep="/")
        htmlwidgets::saveWidget(p, widget_fn)
    }
    
    
    ############## Very slow when using all the genes. Moreover, boundaries need to be added to distinguish the chromosomes #############
    #===============================================================================
    #    Generate heatmap to examine differences across all samples
    #===============================================================================
    #
    ##### Order the data accordingly to genomic postions
    cnData.subset = cnData.subset[order(as.numeric(cnData.pos$Chromosome),as.numeric(cnData.pos$Position)),]
    
    ##### Assign gain for linear CN values above 0.5 and loss for linear CN values below -0.5
    cnData.subset[ cnData.subset > 0.5 ] <- 1
    cnData.subset[ cnData.subset < -0.5 ] <- -1
    cnData.subset[ cnData.subset <= 0.5 & cnData.subset >= -0.5 ] <- 0
    
    ##### Prepare samples annotation info
    annot <- as.matrix(annData[,c(2:ncol(annData))])
    names(annot) <- names(annData)[c(2:ncol(annData))]
    
    ##### Prepare colours for sample groups
    targets.colour <- getTargetsColours(annData[,2])
    
    ##### Transpose matrix
    cnData.subset.t <- data.frame(t(cnData.subset))
    
    ##### Cluster samples
    hr <- hclust(as.dist(dist(cnData.subset.t, method="euclidean")), method="ward.D")
    
    ##### Generate heatmap (PLOTLY)
    p <- heatmaply(data.frame(cbind( cnData.subset.t, annot )), Rowv=as.dendrogram(hr), Colv=NULL, colors = c("blue", "white", "red"), scale="none", trace="none", hide_colorbar = TRUE, fontsize_row = 8, fontsize_col = 8, showticklabels=c(FALSE, TRUE)) %>%
    layout(autosize = TRUE, width = 800, margin = list(l=100, r=50, b=150, t=50, pad=4), showlegend = FALSE)
    
    ##### Save the heatmap as html (PLOTLY)
    widget_fn = paste(outFolder,paste0("heatmap_",j,".html"),sep="/")
    htmlwidgets::saveWidget(p, widget_fn)
    
    
    ##### Close any open graphics devices
    graphics.off()
}

