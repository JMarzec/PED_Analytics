<?php

echo <<< EOT
<div>
    <p>
      Welcome to <b>PED Analytics</b>, a feature for mining and analysing pancreatic-derived -omics data. 
    </p>
    <center>
      <table>
        <tr style='text-align:center'>
          <td>
            <h3> Select the starting point for your analysis </h3>
          </td>
        </tr>
        <tr>
            <td>
                <button class="analysis_sel" id="literature"> PubMed </button>
                <button class="analysis_sel" id="tga"> The Cancer Genome Atlas </button>
                <button class="analysis_sel" id="ccle"> Cancer Cell Line Encyclopedia </button>
            </td>
        </tr>
      </table>
    </center>
</div>
<br><br>

<div class="container" id="description">
  <table id="sel_container">
      <tr>
          The data sources accessed by PED Analytics are datasets publicly-available in <a href="https://www.ebi.ac.uk/arrayexpress/" target="_blank">ArrayExpress</a>, <a href="https://www.ncbi.nlm.nih.gov/geo/" target="_blank">Gene Expression
  Omnibus</a> (GEO), <a href="https://cancergenome.nih.gov/" target="_blank">The Cancer Genome Atlas</a> (TCGA) and the <a href="https://portals.broadinstitute.org/ccle/home" target="_blank">Cancer Cell
  Line Encyclopedia</a> (CCLE). PED Analytic provides you with the means to conduct exploratory and in-depth analyses of transcriptomic,
        sequencing, genomic and mutation data obtained from both tissues and cell lines.<br><br>
          <b>PubMed:</b> An automated data selection and retrieval system has been implemented. Publications of interest are identified from PubMed.
          Gene Expression Omnibus or ArrayExpress identifiers are used to establish computational links between the literature and any associated data.
          If data is available in the public domain, the system accesses the repository and downloads the relevant data files.
          These are fed into the relevant analytical pipelines and made available from the PubMed tab.<br><br>
          <b>The Cancer Genome Atlas:</b> The TCGA consortium is dedicated to the systematic study of alterations in a variety of human cancers.
          It has made publicly available DNA copy number, mRNA expression, methylation and mutation data, alongside its associated clinical data
          for a range of cancer types/subtypes. Currently, mRNA expression  data is available for analysis, with genomic and mutation data to follow shortly.<br><br>
          <b>Cancer Cell Line Encyclopedia:</b> DNA copy number, mRNA expression and mutation data for pancreatic cancer cell lines are available from this tab.
          <br><br>
          Once you have selected a source, you will be directed to a page from which you will be able to conduct multiple analyses:
          principal component analysis (PCA), estimates of tumour purity, gene expression plots, correlation analyses, survival analyses and integrative analyses.

      </tr>
      <!-- Space for some data stats -->
      <!--
      <tr>       
        <td><iframe class="home_stats" scrolling='no' src='stat.html'></iframe></td>
        <td><iframe class="home_stats" scrolling='no' src='stat_analysis.html'></iframe></td>
      </tr>
      -->
  </table>
</div>

<div class="container" id="main"></div>
<div class="container" id="loading"></div>
<div class="container" id="results"></div>


<script> LoadSelector() </script>

EOT;



?>
