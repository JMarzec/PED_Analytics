# PED Analytics
This document describes the [**Analytics**](http://www.analytics.pancreasexpression.org/pages/) component of **Pancreatic Expression Database** (PED).

This PED component was developed to conduct transcriptomic, genomic and mutational analyses using publicly available data. This includes data obtained from [ArrayExpress](https://www.ebi.ac.uk/arrayexpress/), [Gene Expression Omnibus](https://www.ncbi.nlm.nih.gov/geo/) (GEO), [The Cancer Genome Atlas](https://cancergenome.nih.gov/) (TCGA), [Genomics Evidence Neoplasia Information Exchange](http://www.aacr.org/Research/Research/Pages/aacr-project-genie.aspx#.Wrkpy5PwZ25) (GENIE) and the [Cancer Cell Line Encyclopedia](https://portals.broadinstitute.org/ccle/home) (CCLE).


The PED Analytics component is located on SNPnexus server
```
ssh snpadmin@138.37.198.15
```
*NOTE*: login details and password  is provided in a separate file
<br><br>

Version | Website | directory
------------ | ------------ | ------------
Live | http://www.analytics.pancreasexpression.org/pages | /var/www/html/bioinf
Test | http://www.testanalytics.pancreasexpression.org/pages | /var/www/html/bioinf_test
<br />


### Analyses scripts

The R scripts for running individual analysis are located in the following directory
```
/var/www/html/bioinf/pages/scripts
```


Script | Description | Dataset(s)
------------ | ------------ | ------------
*[LiveGeneExpression.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveGeneExpression.R)* | Generates box-plots and bar-plots to visualise expression measurments across samples and groups for user-defined gene | PubMed TCGA CCLE
*[LiveCoExpression.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveCoExpression.R)* | Calculates co-expression of user-defined genes across all samples or samples in user-defined group and presents correlation coefficients between samples as well as associated p-values in a form of correlation matrix heatmap | PubMed TCGA CCLE
*[LiveSurvivalGene.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveSurvivalGene.R)* | Performs survival analysis for user-defined gene | PubMed TCGA
*[LiveNetworkCreator.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveNetworkCreator.R)* | Script for generating interaction networks | PubMed TCGA CCLE
*[LiveExprCN.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveExprCN.R)* | Generates box-plot and scatter-plot with expression data and copy-number data for user-defined gene on the Y and X axis, respectively. The samples are coloured based on the biological group from the target file | CCLE
*[LiveExprCNMut.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveExprCNMut.R)* | Generates box-plot and scatter-plot with expression data and copy-number data for user-defined gene on the Y and X axis, respectively. The samples are coloured based on the mutation status of the corresponding gene | TCGA CCLE
*[LiveCNAlterations.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveCNAlterations.R)* | Generates heatmap with copy-number status for user-defined genes across all samples. It uses a continuos copy-number data as input | CCLE
*[LiveCNAlterations_binary.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveCNAlterations_binary.R)* | Generates heatmap with copy-number status for user-defined genes across all samples. It uses a binarised copy-number data (-2 = deletion, -1 = loss, 0 = diploid, 1 = gain, 2 = amplification) as input | TCGA
*[LiveCNAlterations_annot_binary.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveCNAlterations_annot_binary.R)* | Generates heatmap with copy-number status for user-defined genes across all samples. It uses a binarised copy-number data (-2 = deletion, -1 = loss, 0 = diploid, 1 = gain, 2 = amplification) as input. The samples annotation is presented at the top of the heatmap | GENIE
*[LiveMutFreq.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveMutFreq.R)* | Generates a horizontal bar-plot illustrating the frequency of various mutations for the user-defined gene | GENIE
*[LiveFusionsFreq.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/pages/scripts/LiveFusionsFreq.R)* | Generates a horizontal bar-plot illustrating the frequency of various fusions for the user-defined gene | GENIE
<br />


### Populating MySQL database

Conncet to SNPnexuys server
```
ssh snpadmin@138.37.198.15
```
*NOTE*: login details and password  is provided in a separate file


Import the dumped sql file into the new database
```
cd /var/www/html/bioinf/ped_backoffice

mysql -u snp -p ped_bioinf_portal < ped_bioinf_portal.sql
```

Check the database content
```
mysql -u snp -p

USE ped_bioinf_portal;

SHOW TABLES;

DESCRIBE Articles;

quit;
```
<br>


#### PubMed
Example of adding a PubMed study into *Articles*
```
INSERT INTO Articles (ID, PMID, Title, Authors, Journal, Abstract, PubDate, Ranking, Analysis, Cohort, Groups) VALUES (35, 19917848, "Pancreatic endocrine tumors: expression profiling evidences a role for AKT-mTOR pathway.", "Missiaglia E, Dalai I, Barbi S, Beghelli S, Falconi M, della Peruta M, Piemonti L, Capurso G, Di Florio A, delle Fave G, Pederzoli P, Croce CM, Scarpa A.", "Journal of Clinical Oncology", "PURPOSE:
We investigated the global gene expression in a large panel of pancreatic endocrine tumors (PETs) aimed at identifying new potential targets for therapy and biomarkers to predict patient outcome. PATIENTS AND METHODS: Using a custom microarray, we analyzed 72 primary PETs, seven matched metastases, and 10 normal pancreatic samples. Relevant differentially expressed genes were validated by either quantitative real-time polymerase chain reaction or immunohistochemistry on tissue microarrays. RESULTS: Our data showed that: tuberous sclerosis 2 (TSC2) and phosphatase and tensin homolog (PTEN) were downregulated in most of the primary tumors, and their low expression was significantly associated with shorter disease-free and overall survival; somatostatin receptor 2 (SSTR2) was absent or very low in insulinomas compared with nonfunctioning tumors; and expression of fibroblast growth factor 13 (FGF13) gene was significantly associated with the occurrence of liver metastasis and shorter disease-free survival. TSC2 and PTEN are two key inhibitors of the Akt/mammalian target of rapamycin (mTOR) pathway and the specific inhibition of mTOR with rapamycin or RAD001 inhibited cell proliferation of PET cell lines. CONCLUSION: Our results strongly support a role for PI3K/Akt/mTOR pathway in PET, which ties in with the fact that mTOR inhibitors have reached phase III trials in neuroendocrine tumors. The finding of differential SSTR expression raises the potential for SSTR expression to be evaluated as a marker of response to somatostatin analogs. Finally, we identified FGF13 as a new prognostic marker that predicted poorer outcome in patients who were clinically considered free from disease.", "2010-01-10", 0, "PCA,Tumour purity,Expression profiles,Expression correlations,Gene networks", 1, "Metastases from PanNET,Normal pancreas,Normal pancreas islet,PanNET");
```
<br>

#### TCGA
To populate TCGA table use the [*populate_tcga_db.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_tcga_db.py) script or [*populate_tcga_db_local.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_tcga_db_local.py) script, if executed on local machine rather than on the SNPnexus server (see [Update MySQL database using Stefano's script](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics#update-mysql-database-using-stefanos-script0) section). It reads the [*TCGA_PAAD_target_full.txt*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/TCGA_PAAD_target_full.txt) file with the samples annotations to be presented on on top of the TCGA tab in PED Analytics.
```
cd /var/www/html/bioinf/ped_backoffice/various_scripts

populate_tcga_db.py --tcga TCGA_PAAD_target_full.txt
```
<br>

#### GENIE
To populate GENIE table use the [*populate_genie_db_local.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_genie_db_local.py) script. It reads the *GENIE_target_full.txt* file with the samples annotations to be presented on on top of the GENIE tab.
```
populate_genie_db.py --tcga GENIE_target_full.txt
```
<br>

#### CCLE
To populate CCLE table use the [*populate_ccle_db.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_ccle_db.py) script or [*populate_ccle_db_local.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_ccle_db_local.py) script. It reads the *CCLE_PC_target_full.txt* file with the samples annotations to be presented on on top of the CCLE tab.
```
populate_ccle_db.py --tcga CCLE_PC_target_full.txt
```
<br>

#### ICGC
To populate ICGC table use the [*populate_icgc_db.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_icgc_db.py) script or [*populate_icgc_db_local.py*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/various_scripts/populate_icgc_db_local.py) script. It reads the *ICGC_target_full.txt* file with the samples annotations to be presented on on top of the ICGC tab.
```
populate_icgc_db.py --icgc ICGC_target_full.txt
```
<br>

### Update MySQL database using Stefano's script

First, one needs to update the analyses.report file with lists datasets with corresponding analyses
```
vi /var/www/html/bioinf/ped_backoffice/scripts/analyses.report
```

*NOTE*: Make sure to use python3 to run the script *upload_completed_analysis.py*
```
python --version
```

If the python2 is default
```
alias python=python3
```
...or simply execute the command with by calling *python3*
```
/opt/python3/bin/python3 upload_completed_analysis.py  --report analyses.report
```

In case there are still problems with using the right python version, one needs to run the *upload_completed_analysis_local.py* script on local machine and then dump the database and import on SNPnexus server. This script is the same as the *upload_completed_analysis_local.py* apart from that it uses the MySQL username and password for the local machine.

Steps to perform on local machine
```
cd /Users/marzec01/biomart/PED_bioinformatics_portal/ped_backoffice/scripts

python upload_completed_analysis_local.py  --report analyses.report

mysqldump -u root -p  ped_bioinf_portal > ped_bioinf_portal.sql
```

...and on SNPnexus server
```
cd /var/www/html/bioinf/ped_backoffice

mysql -u biomart -p ped_bioinf_portal < ped_bioinf_portal.sql
```
<br>

### Add PubMed datasets manually
The **datasets available in PED Analytics** are summarised in **[PC_datasets_transcriptomics_for_data_portal.xlsx](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/data/PC_datasets_transcriptomics_for_data_portal.xlsx)** spreadsheet.


Sometimes some datasets are not reported by SMAC, e.g. when the dataset in ArrayExpress or GEO is not linked with PubMed ID, or if the normalised data is missing, which is usually the case for RNA-seq studies. To add these studies to PED Analytics one needs to follow the steps below.

Dataset *E-GEOD-73514 (GSE73514)* associated with publication with *PMID 26446169* is used as an example.

First, and the data with relevant folder structure, e.g.
```
/var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169

-E-GEOD-73514_26446169
 |
 |-norm_files
 | \-73514_1.processed.genename.csv
 |
 |-target_for_estimate.txt
 \-target.orig.txt
```

1. Run ESTIMATE analysis scripts [*bcntb.estimate.R*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/scripts/bcntb.estimate.R) and [*bcntb.plotly.estimate.R*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/scripts/bcntb.plotly.estimate.R)
```
cd /var/www/html/bioinf/ped_backoffice/scripts

Rscript bcntb.estimate.R --exp_file 73514_1.processed.genename.csv --target /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169/target_for_estimate.txt  --target2 /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169/target.txt --dir /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169

Rscript bcntb.plotly.estimate.R --report /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169/estimate.report --dir /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169
```
<br>

2. Run PCA analysis script [*bcntb.pca.R*](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/scripts/bcntb.pca.R)
```
Rscript bcntb.pca.R --exp_file 73514_1.processed.genename.csv --target /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169/target.txt --colouring Target --principal_component 1 --dir /var/www/html/bioinf/ped_backoffice/data/E-GEOD-73514_26446169
```
<br>

3. Add associated paper to the database
```
mysql -u snp -p

USE ped_bioinf_portal;

INSERT INTO Articles (ID, PMID, Title, Authors, Journal, Abstract, PubDate, Ranking, Analysis, Cohort, Groups) VALUES (35, 19917848, "Pancreatic endocrine tumors: expression profiling evidences a role for AKT-mTOR pathway.", "Missiaglia E, Dalai I, Barbi S, Beghelli S, Falconi M, della Peruta M, Piemonti L, Capurso G, Di Florio A, delle Fave G, Pederzoli P, Croce CM, Scarpa A.", "Journal of Clinical Oncology", "PURPOSE:
We investigated the global gene expression in a large panel of pancreatic endocrine tumors (PETs) aimed at identifying new potential targets for therapy and biomarkers to predict patient outcome. PATIENTS AND METHODS: Using a custom microarray, we analyzed 72 primary PETs, seven matched metastases, and 10 normal pancreatic samples. Relevant differentially expressed genes were validated by either quantitative real-time polymerase chain reaction or immunohistochemistry on tissue microarrays. RESULTS: Our data showed that: tuberous sclerosis 2 (TSC2) and phosphatase and tensin homolog (PTEN) were downregulated in most of the primary tumors, and their low expression was significantly associated with shorter disease-free and overall survival; somatostatin receptor 2 (SSTR2) was absent or very low in insulinomas compared with nonfunctioning tumors; and expression of fibroblast growth factor 13 (FGF13) gene was significantly associated with the occurrence of liver metastasis and shorter disease-free survival. TSC2 and PTEN are two key inhibitors of the Akt/mammalian target of rapamycin (mTOR) pathway and the specific inhibition of mTOR with rapamycin or RAD001 inhibited cell proliferation of PET cell lines. CONCLUSION: Our results strongly support a role for PI3K/Akt/mTOR pathway in PET, which ties in with the fact that mTOR inhibitors have reached phase III trials in neuroendocrine tumors. The finding of differential SSTR expression raises the potential for SSTR expression to be evaluated as a marker of response to somatostatin analogs. Finally, we identified FGF13 as a new prognostic marker that predicted poorer outcome in patients who were clinically considered free from disease.", "2010-01-10", 0, "PCA,Tumour purity,Expression profiles,Expression correlations,Gene networks", 1, "Metastases from PanNET,Normal pancreas,Normal pancreas islet,PanNET");

SELECT PMID from Articles where PMID=19917848;
```
<br>

4. If the MySQL database was update on local machine then dump it and import into the database on SNPnexus server

Dump updated database
```
cd /Users/marzec01/Desktop/git/PED_bioinformatics_portal/PED_Analytics/ped_backoffice
mysqldump -u root -p  ped_bioinf_portal > ped_bioinf_portal.sql
```

Import updated database into MySQL on SNPNexus server
```
scp ped_bioinf_portal.sql snpadmin@138.37.198.15:/var/www/html/bioinf/ped_backoffice

cd /var/www/html/bioinf/ped_backoffice
mysql -u snp -p ped_bioinf_portal < ped_bioinf_portal.sql
```
<br>

*Note*: Sometimes the expression data is provided as one file per sample rather than as an expression matrix (e.g. dataset *E-GEOD-71729*). This is usually the case of datasets. To merge these files into one matrix use [merge_samples2matrix.R](https://github.research.its.qmul.ac.uk/hfw456/PED_Analytics/tree/master/ped_backoffice/data/merge_samples2matrix.R) script, e.g.
```
cd /var/www/html/bioinf/ped_backoffice/data
Rscript merge_samples2matrix.R --inDir E-GEOD-71729_26343385/norm_files --outFile E-GEOD-71729.merged.txt
```
<br>


### To do list
- Add ICGC data (PACA-AU, PACA-CA, PAEN-AU and PAEN-IT). Combine Pancreatic Cancer datasets (PACA-AU and PACA-CA) and Pancreatic Cancer Endocrine Neoplasms datasets (PAEN-AU and PAEN-IT). For the expression data, it is necessary to investigate it with PCA. If the Z-score transformed data presents project-specific effects then use [*ComBat*](https://www.ncbi.nlm.nih.gov/pubmed/16632515) to remove them.
- Kaplan Meier plot for mutation data. Use mutation status as an input instead of expression values used in the traditional survival analysis and link the mutation status for user-defined gene with survival data
- Add survival data to Bailey study (dataset: E-GEOD-36924, PMID: 26909576)
- Investigate why some edges in the gene network plot are yellow instead of reflecting the expression level (as the nodes do)
- Reorder the expression matrices by gene names so that the genes in drop-down lists appear alphabetically
- Fix the mutations categories in GENIE mutation profiling analysis. Sometimes the mutations category have inverted names, e.g. for *TP53* there are *Nonsense & Missense* as well as *Missense & Nonsense* mutation categories, which is probably due multiple mutation types in that gene occurring in different order in various patients
- Implement a pop-up window for selected plots so that they are expanded and full view is available for download (in png format)
- Investigate the best cut-off threshold for presenting the CIRCOS plots (liaise with Dayem)
