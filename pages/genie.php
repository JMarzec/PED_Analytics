<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = "$relative_root_dir/ped_backoffice/data/genie/";
$result_directory = "$absolute_root_dir/ped_backoffice/data/genie/";

echo <<< EOT
  <!-- Results Section -->
    <table id="genie" class="display DataTable compact" cellspacing="0" width="100%">
        <!-- Table Header -->
        <thead>
            <tr>
                <th>Name</th>
                <th>Target</th>
                <th>Cancer type</th>
                <th>Gender</th>
                <th>Ethnicity</th>
                <th>Race</th>
                <th>Age</th>
            </tr>
        </thead>
        <!-- Table Footer -->
        <tfoot>
            <tr>
                <th>Name</th>
                <th>Target</th>
                <th>Cancer type</th>
                <th>Gender</th>
                <th>Ethnicity</th>
                <th>Race</th>
                <th>Age</th>
            </tr>
        </tfoot>
    </table>

  <div class="container" id="genie_results">
    <ul>
      <!-- Rremove mutations section until we have ready script for interactive plots
      <li><a href="#oncoprint">Mutations</a></li>
      -->
      <li><a href="#copy_number_alterations">Copy number alterations</a></li>
      <li><a href="#gene_copy_number">Gene copy number</a></li>
      <!-- 
      <li><a href="#expression_layering">Data integration</a></li>
      -->
    </ul>

    <div id="expression_layering">
      <div class='description'>
        <p class='pub_det'>
          This analytical module allows to integrate and visualise discrete genetic events,
          such as DNA copy-number alterations (CNAs) and mutations,
          or relative linear copy-number values with continuous mRNA abundance
          data for user-defined gene.
        </p>
        <br><br>
        <h4> Please select a gene of interest </h4>
        <br>
        <u class=note> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>

      <!-- putting gene selector -->
      <select id="el_genie_sel"> </select>
      <button id="el_genie_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='el_genie' id='el_genie'></div>
      <iframe class='results' id='el_genie_sel_boxel_mut'></iframe>
      <iframe class='results' id='el_genie_sel_el_mut'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("el_genie_sel", "", "", "ccle")</script>
      <script>LoadAnalysis("el_genie_sel","el_genie_run","genie","","genie_expression_layering","1")</script>
    </div>

    <div id="copy_number_alterations">
      <div class='description'>
        <p class='pub_det'>
          An overview of DNA copy number alterations (CNA) are presented as frequency plots.
          From here, you can view the CNA specific to the dataset selected and the biological groups available.
        </p>
      </div>

      <!-- Loading div -->
      <div class='fcna_genie' id='fcna_genie'>
        <div id='download' style='padding-top:40px'></div>
        <iframe class='results' id='cna_1' src='$iframe_directory/frequency_plot_1_1.html' onload='resizeIframe(this)'></iframe>
      </div>
    </div>

    <div id="gene_copy_number">
      <div class='description'>
        <p class='pub_det'>
          The copy number of selected genes across cell lines are presented as heatmap with genes and samples are represented by rows and columns, respectively.
        </p>
        <br><br>
        <h4> Please select at least 2 genes of interest (max 20 genes)</h4>
        <br>
        <u class="note"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>

      <!-- putting gene selector -->
      <select multiple id="cna_genie_sel"> </select>
      <br><br><br>
      <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
      <br><br>
      <textarea id='textcna_genie_sel' rows='3' cols='80'></textarea>
      <br>
      <button id="cna_genie_run" class="run"> Run analysis </button>
      <br><br>

      <div class='cna_genie' id='cna_genie'></div>

      <!-- Loading div -->
      <div class='cna_genie' id='cna_genie'>
        <iframe class='results' id='cna_hm' onload='resizeIframe(this)'></iframe>
      </div>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("cna_genie_sel", "", "", "genie_cnv")</script>
      <script>LoadAnalysis("cna_genie_sel","cna_genie_run","genie","","genie_gene_copy_number","1")</script>
    </div>
  </div>

  <script> LoadGENIETable() </script>
  <script> LoadGENIETabs() </script>

EOT;
?>
