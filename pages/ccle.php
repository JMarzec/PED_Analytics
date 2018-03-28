<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = "$relative_root_dir/ped_backoffice/data/ccle/";
$result_directory = "$absolute_root_dir/ped_backoffice/data/ccle";

echo <<< EOT
  <!-- Results Section -->
    <table id="ccle" class="display DataTable compact" cellspacing="0" width="100%">
        <!-- Table Header -->
        <thead>
            <tr>
                <th>Name</th>
                <th>Target</th>
                <th>Type</th>
                <th>Gender</th>
                <th>Ethnicity</th>
                <th>Age</th>
            </tr>
        </thead>
        <!-- Table Footer -->
        <tfoot>
            <tr>
                <th>Name</th>
                <th>Target</th>
                <th>Type</th>
                <th>Gender</th>
                <th>Ethnicity</th>
                <th>Age</th>
            </tr>
        </tfoot>
    </table>

  <div class="container" id="ccle_results">
    <ul>
      <li><a href="#pca">PCA</a></li>
      <li><a href="#expression_profiles">Gene expression</a></li>
      <li><a href="#co_expression_analysis">Expression correlations</a></li>
      <li><a href="#copy_number_alterations">Copy number alterations</a></li>
      <li><a href="#gene_copy_number">Gene copy number</a></li>
      <li><a href="#expression_layering">Data integration</a></li>
      <li><a href="#gene_networks">Gene networks</a></li>
    </ul>
    <div id="pca">
      <div class='description'>
        <p class='pub_det'> Principal component analyses (PCA) transforms the data into a coordinate system and presenting it as an orthogonal projection.
            This reduces the dimensionality of the data, allowing for the global structure and key “components” of variation of the data to be viewed.
            Each point represents the orientation of a sample in the transcriptional space projected on the PCA,
            with different colours representing the biological group of the sample.
        </p>
      </div>

      <iframe class='results' scrolling='no' src='$iframe_directory/pca_2d_1.html'></iframe>
      <iframe class='results' scrolling='no' src='$iframe_directory/pca_3d_1.html'></iframe>
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
        <u class=note> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>
      <!-- putting gene selector -->
      <select id="gea_ccle_sel"> </select>
      <button id="gea_ccle_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='gea_ccle' id='gea_ccle'></div>
      <iframe class='results' id='gea_ccle_sel_box'></iframe>
      <iframe class='results' id='gea_ccle_sel_bar'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("gea_ccle_sel", "", "", "ccle")</script>
      <script>LoadAnalysis("gea_ccle_sel","gea_ccle_run","ccle","","ccle_gene_expression","1")</script>
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
        <u class=note> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>
      <!-- putting gene selector -->
      <select multiple id="cea_ccle_sel"> </select>
      <br><br><br>
      <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
      <br><br>
      <textarea id='textcea_ccle_sel' rows='3' cols='80'></textarea>
      <br>
      <button id="cea_ccle_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='cea_ccle' id='cea_ccle'></div>
      <iframe class='results' id='cea_ccle_sel_hm'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("cea_ccle_sel", "", "", "ccle")</script>
      <script>LoadAnalysis("cea_ccle_sel","cea_ccle_run","ccle","","ccle_co_expression","1")</script>
    </div>

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
      <select id="el_ccle_sel"> </select>
      <button id="el_ccle_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='el_ccle' id='el_ccle'></div>
      <iframe class='results' id='el_ccle_sel_boxel'></iframe>
      <iframe class='results' id='el_ccle_sel_el'></iframe>
      <iframe class='results' id='el_ccle_sel_boxel_mut'></iframe>
      <iframe class='results' id='el_ccle_sel_el_mut'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("el_ccle_sel", "", "", "el_ccle")</script>
      <script>LoadAnalysis("el_ccle_sel","el_ccle_run","ccle","","ccle_expression_layering","1")</script>
    </div>

    <div id="copy_number_alterations">
      <div class='description'>
        <p class='pub_det'>
          An overview of DNA copy number alterations (CNA) are presented as frequency plots.
          From here, you can view the CNA specific to the dataset selected and the biological groups available.
        </p>
      </div>

      <!-- Loading div -->
      <div class='fcna_ccle' id='fcna_ccle'>
        <div id='download' style='padding-top:40px'></div>
            <iframe class='results' id='cna_1' src='$iframe_directory/frequency_plot_1_1.html' onload='resizeIframe(this)'></iframe>
            <iframe class='results' id='cna_4' src='$iframe_directory/frequency_plot_1_4.html' onload='resizeIframe(this)'></iframe>
            <iframe class='results' id='cna_5' src='$iframe_directory/frequency_plot_1_5.html' onload='resizeIframe(this)'></iframe>
            <iframe class='results' id='cna_3' src='$iframe_directory/frequency_plot_1_3.html' onload='resizeIframe(this)'></iframe>
            <iframe class='results' id='cna_2' src='$iframe_directory/frequency_plot_1_2.html' onload='resizeIframe(this)'></iframe>
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
      <select multiple id="cna_ccle_sel"> </select>
      <br><br><br>
      <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
      <br><br>
      <textarea id='textcna_ccle_sel' rows='3' cols='80'></textarea>
      <br>
      <button id="cna_ccle_run" class="run"> Run analysis </button>
      <br><br>

      <div class='cna_ccle' id='cna_ccle'></div>

      <!-- Loading div -->
      <div class='cna_ccle' id='cna_ccle'>
        <iframe class='results' id='cna_hm' onload='resizeIframe(this)'></iframe>
      </div>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("cna_ccle_sel", "", "", "ccle_cnv")</script>
      <script>LoadAnalysis("cna_ccle_sel","cna_ccle_run","ccle","","ccle_gene_copy_number","1")</script>

    </div>

    <div id='gene_networks'>
      <div class='description'>
        <p class='pub_det'>
          Here we present an interactive tool to explore interactions among proteins of interest.
        </p>
        <br><br>
          <table id='network_parameters_container'>
            <tr style='height:70px; vertical-align:top'>
              <td colspan=2>
                <h4> Please select the genes of interest (maximum 5 genes) </h4>
                <br>
                <u class="note"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
                <br><br>
                <select multiple id='ccle_net_sel'></select>
                <br><br>
              </td>
            </tr>
            <tr>
              <td>
                <h4> Please select the interaction score threshold </h4>
                <br><br>
                <div id='mentha-score'></div>
                <!-- loading threshold labels -->
                <input type='text' id='min_thr_label' readonly>
                <input type='text' id='max_thr_label' readonly>
              </td>
              <td>
                <button id="ccle_run_net" class="run"> Run analysis </button>
              </td>
            </tr>
          </table>

          <!-- load legend div -->
          <div id='net_legend' title='Network legend' style='display:none'>
            <img src='../images/net_legend.svg'
          </div>

      </div>

      <div class='net_ccle' id='net_ccle'></div>

      <!-- loading graph container when result launched -->
      <div class='network_container' id='GraphContainerNET'>
        <!-- initializing hidden value for random code (useful for changing graph later) -->
        <input type='hidden' id='random_code'/>
        <table>
          <tr>
            <h4> Speciments available in the dataset: </h4><br>

EOT;
      // loading multiple radio buttons according to the speciments into the target file
      $target_io = fopen("$result_directory/cn_target.txt", "r");
      // initilizing array with speciments
      $all_specimens = array();
      // removing first line
      $headers = fgetcsv($target_io, 1000, "\t");
      while (($target = fgetcsv($target_io, 1000, "\t")) !== FALSE) {
        $target = array_combine($headers, $target);
        // here we change the target column to see if the dataset has been curated by Ema or not
        $all_specimens[] = $target["Target"];
      }
      fclose($target_io);
      // uniquing specimens
      $all_specimens = array_unique($all_specimens);

      // listing speciments
      $cont_specimen = 0;
      foreach ($all_specimens as &$specimen) {
        if ($cont_specimen==0) {
          echo "<td style=\"padding-right:10px;\"><input type=\"radio\" name=\"selector\" checked onclick=LoadNetworkGraph('".$cont_specimen."'); />".$specimen."</td>";
        } else {
          echo "<td style=\"padding-right:10px;\"><input type=\"radio\" name=\"selector\" style=\"margin-right:10px;\" onclick=LoadNetworkGraph('".$cont_specimen."'); />".$specimen."</td>";
        }
        $cont_specimen++;
      }

  echo "   </tr>
        </table>";

  echo <<< EOT

        <!-- inserting legend for color nodes -->
        <br><br>
        <img src='../images/question_mark.png' onClick='LoadLegend()' style='width:30px; height:30px'>
        <iframe class='results' id='network_container' onload='resizeIframe(this);'></iframe>

        <!-- loading table with interactions -->
        <table id='network_details' class='table table-bordered results' cellspacing='0' width='100%'>
          <thead>
            <tr>
              <th>Source Gene (SG)</th>
              <th>Expression SG</th>
              <th>Target Gene (TG)</th>
              <th>Expression TG</th>
              <th>PMIDs</th>
          </thead>
          <tbody>
          </tbody>
        </table>
      </div>

      <!-- loading javascripts -->
      <script>LoadScoreSlider('mentha-score')</script>
      <script>LoadGeneSelector('ccle_net_sel','','','ccle')</script>
      <script>LoadAnalysis('ccle_net_sel','ccle_run_net','','','ccle_gene_network','0')</script>
    </div>
  </div>

  <script> LoadCCLETable() </script>
  <script> LoadCCLETabs() </script>

EOT;
?>
