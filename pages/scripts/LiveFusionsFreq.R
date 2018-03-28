################################################################################
#
#   File name: LiveFusionsFreq.R
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
#   Command line use example: Rscript LiveFusionsFreq.R --mut_file /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/genie/norm_files/fusions.csv --target /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/genie/gea_target.txt --gene KRAS --colouring Target --dir /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice/data/genie --hexcode fdshf
#
#   First arg:      Full path with name of the relative linear copy-number matrix
#   Second arg:     Full path with name of the file with gene fusions data. This file is expected contain the following information: (1) sample name, (2) gene name and (3) variant classification
#   Third arg:      Full path with name of the text file with samples annotation. The file is expected to include the following columns: sample name (1st column) and annotation (3rd column)
#   Fourth arg:     ID of gene/probe of interest
#   Fifth arg:      Full path with name of the output folder

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
suppressMessages(library(dplyr))
suppressMessages(library(optparse))

#===============================================================================
#    Catching the arguments
#===============================================================================
option_list = list(
  make_option(c("-m", "--mut_file"), action="store", default=NA, type='character',
              help="File containing fusions data"),
  make_option(c("-t", "--target"), action="store", default=NA, type='character',
              help="Clinical data saved in tab-delimited format"),
  make_option(c("-p", "--gene"), action="store", default=NA, type='character',
              help="ID of gene/probe of interest"),
  make_option(c("-c", "--colouring"), action="store", default=NA, type='character',
              help="Variable from the samples annotation file to be used for samples colouring"),
  make_option(c("-d", "--dir"), action="store", default=NA, type='character',
              help="Default directory"),
  make_option(c("-x", "--hexcode"), action="store", default=NA, type='character',
              help="unique_id to save temporary plots")
)

opt = parse_args(OptionParser(option_list=option_list))

mutFile <- opt$mut_file
annFile <- opt$target
target <- opt$colouring
gene <- opt$gene
outFolder <- opt$dir
hexcode <- opt$hexcode

#===============================================================================
#    Main
#===============================================================================

gene = make.names(gene)

##### Read maf file with fusions data
mutData <- read.table(mutFile,sep="\t",as.is=TRUE,header=TRUE,row.names=NULL)
mutData[,1] <- make.names(mutData[,1])

##### Read sample annotation file
annData <- read.table(annFile,sep="\t",as.is=TRUE,header=TRUE)
annData$File_name <- make.names(annData$File_name)


##### Keep only samples with annotation info
mutData <- mutData[mutData[,1] %in% annData$File_name, ]


##### Check if the queried genes is present in the fusions data
if ( gene %!in% mutData[,2] ) {
    #cat("The gene/probe", gene, "is not present in the data!", sep=" ")
    q()

##### ... and extract the expression of the gene of inteterest
} else {
    gene.mut <- mutData[mutData[,2]==gene, ]
}

# Change working directory to the project workspace
setwd(outFolder)


# # Report samples not present in the CN matrix
# if ( length(absentSamples.cnData) > 0 ) {
#     write(absentSamples.cnData, file = paste(coreName, gene, "absent_in_CN_data.txt", sep = "_"), append = FALSE, sep="\t",  quote=FALSE)
# }


#===============================================================================
#     Prepare the gene fusions file
#===============================================================================

##### Initiate variable for the gene fusions status for each sample
gene.mut.sample <- as.matrix(rep("No fusion", nrow(annData)))
colnames(gene.mut.sample) <- "Fusion"
rownames(gene.mut.sample) <- annData$File_name


for ( i in 1:nrow(annData) ) {

    if (  gene.mut[i,1] %in% annData$File_name ) {

        ##### If for a specific sample more than one fusion in the queried genes is provided then the the additional fusion categories will be also provided
        if ( gene.mut.sample[gene.mut[i,1],"Fusion"] != "No fusion"  ) {

            gene.mut.sample[gene.mut[i,1],"Fusion"] <- paste(gene.mut.sample[gene.mut[i,1],"Fusion"], gene.mut[i,3], sep=" & ")

        } else {

            gene.mut.sample[gene.mut[i,1],"Fusion"] <- gene.mut[i,3]
        }
    }
}


#===============================================================================
#     Generate mRNA expression vs putative DNA copy-number alterations box-plot
#===============================================================================

targets <- annData[,target]
targets.colour <- getTargetsColours(targets)

muts <- gene.mut.sample[,"Fusion"]

gene.df <- data.frame(muts, targets)
colnames(gene.df) <- c("Fusion", "Target")


##### Generate horizontal bar plot with bar for each group
p <- gene.df %>% count(Target, Fusion) %>%
plot_ly(x = ~n, y = ~Target, color = ~Fusion, type='bar', orientation = "h", width = 800, height = length(unique(targets))*38, marker = list(line = list(color = 'rgba(0, 0, 0, 0.4)', width = 1)))  %>%

layout(
  title = "",
  xaxis = list(title = paste0(gene, " fusion frequency")),
  yaxis = list(title = ""),
  margin = list(l=400, r=50, b=50, t=50, pad=4),
  autosize = F,
  barmode = 'stack'
)

##### Save the box-plot as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), paste0(hexcode, "_mutFreq.html"), selfcontained = FALSE)


##### Clear workspace
rm(list=ls())
##### Close any open graphics devices
graphics.off()
