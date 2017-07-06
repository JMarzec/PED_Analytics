<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = "$relative_root_dir/ped_backoffice/data/tcga/";

echo <<< EOT
  <!-- Results Section -->
    <table id="tcga" class="display DataTable compact" cellspacing="0" width="100%">
        <!-- Table Header -->
        <thead>
            <tr>
                <th>Name</th>
                <th>Target</th>
                <th>Age</th>
                <th>Smoking (years)</th>
                <th>Alcohol history</th>
                <th>Gender</th>
                <th>Tumor stage</th>
                <th>TNM staging</th>
                <th>Histologic Grade</th>
            </tr>
        </thead>
        <!-- Table Footer -->
        <tfoot>
            <tr>
                <th>Name</th>
                <th>Target</th>
                <th>Age</th>
                <th>Smoking (years)</th>
                <th>Alcohol history</th>
                <th>Gender</th>
                <th>Tumor stage</th>
                <th>TNM staging</th>
                <th>Histologic Grade</th>
            </tr>
        </tfoot>
    </table>  
    
  <div class="container" id="tcga_results">
    <ul>
      <li><a href="#pca">PCA</a></li>
      <li><a href="#expression_profiles">Gene expression</a></li>
      <li><a href="#co_expression_analysis">Correlations</a></li>
      <!-- Rremove mutations section until we have ready script for interactive plots
      <li><a href="#oncoprint">Mutations</a></li>
      -->
    </ul>
    <div id="pca">
      <div class='description'>
        <p class='pub_det'> Principal component analyses (PCA) transforms the data into a coordinate system and presenting it as an orthogonal projection.
            This reduces the dimensionality of the data, allowing for the global structure and key “components” of variation of the data to be viewed.
            Each point represents the orientation of a sample in the transcriptional space projected on the PCA,
            with different colours representing the biological group of the sample.
        </p>
      </div>

      <iframe class='results' scrolling='no' src='$iframe_directory/pca3d_1.html'></iframe>
      <iframe class='results' scrolling='no' src='$iframe_directory/pca2d_1.html'></iframe>
      <iframe class='results' scrolling='no' src='$iframe_directory/pca_bp_1.html'></iframe>

    </div>
    <div id="expression_profiles">
      <div class='description'>
        <p class='pub_det'>
          The expression profile of selected gene(s) across comparative groups are presented as both summarised and a
          sample views (boxplots and barplots, respectively).
        </p>
        <br><br>
        <h4> Please select a gene of interest </h4>
        <br>
      </div>
      <!-- putting gene selector -->
      <select id="gea_tcga_sel"> </select>
      <button id="gea_tcga_run"> Run analysis </button>

      <!-- Loading div -->
      <div class='gea_tcga' id='gea_tcga'></div>
      <iframe class='results' id='gea_tcga_sel_box'></iframe>
      <iframe class='results' id='gea_tcga_sel_bar'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("gea_tcga_sel", "", "", "tcga")</script>
      <script>LoadAnalysis("gea_tcga_sel","gea_tcga_run","tcga","","tcga_gene_expression","0")</script>
    </div>

    <div id="co_expression_analysis">
      <div class='description'>
        <p class='pub_det'>
          We offer users the opportunity to identify genes that are co-expressed with their gene(s) of interest.
          This value is calculated using the Pearson Product Moment Correlation Coefficient (PMCC) value.
          Correlations for the genes specified by the user are presented in a heatmap.
        </p>
        <br><br>
        <h4> Please select at least 2 genes of interest (max 50 genes)</h4>
        <br>
      </div>
      <!-- putting gene selector -->
      <select multiple id="cea_tcga_sel"> </select>
      <button id="cea_tcga_run"> Run analysis </button>

      <!-- Loading div -->
      <div class='cea_tcga' id='cea_tcga'></div>
      <iframe class='results' id='cea_tcga_sel_hm'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("cea_tcga_sel", "", "", "tcga")</script>
      <script>LoadAnalysis("cea_tcga_sel","cea_tcga_run","tcga","","tcga_co_expression","1")</script>
    </div>
 <!-- Rremove mutations section until we have ready script for interactive plots
    <div id="oncoprint">
      <center>
        <img src='$iframe_directory/oncoprint.png' style="width: 800px">
      </center>
    </div>
  -->

    <script> LoadTCGATable() </script>
    <script> LoadTCGATabs() </script>
  </div>
EOT;
?>
