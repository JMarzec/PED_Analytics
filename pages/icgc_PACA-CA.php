<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = "$relative_root_dir/ped_backoffice/data/icgc_PACA-CA/";
$result_directory = "$absolute_root_dir/ped_backoffice/data/icgc_PACA-CA/";

echo <<< EOT
  <!-- Results Section -->
    <table id="icgc" class="display DataTable compact" cellspacing="0" width="100%">
        <!-- Table Header -->
        <thead>
            <tr>
                <th>Project</th>
                <th>Cancer type</th>
                <th>Samples (expression)</th>
                <th>Samples (survival)</th>
                <th>Samples (copy number)</th>
                <th>Samples (mutation)</th>
            </tr>
        </thead>
        <!-- Table Footer -->
        <tfoot>
            <tr>
                <th>Project</th>
                <th>Cancer type</th>
                <th>Samples (expression)</th>
                <th>Samples (survival)</th>
                <th>Samples (copy number)</th>
                <th>Samples (mutation)</th>
            </tr>
        </tfoot>
    </table>
    
        <center>
      <table>
        <tr style='text-align:center'>
          <td>
            <h3> Select ICGC project </h3>
          </td>
        </tr>
        <tr>
            <td>
                <button class="analysis_sel" id="ICGC_PACA-AU"> PACA-AU </button>
                <button class="analysis_sel" id="ICGC_PACA-CA"> PACA-CA </button>
                <button class="analysis_sel" id="ICGC_PAEN-AU"> PAEN-AU </button>
                <button class="analysis_sel" id="ICGC_PAEN-IT"> PAEN-IT </button>
            </td>
        </tr>
      </table>
    </center>
    <br><br>
    
  <div class="container" id="icgc_results">
    <ul>
      <li><a href="#pca">PCA</a></li>
      <!-- Exclude clustering/heatmap for now
      <li><a href="#expression_clustering">Clustering</a></li>
      -->
      <li><a href="#expression_profiles">Gene expression</a></li>
      <li><a href="#co_expression_analysis">Expression correlations</a></li>
      <!-- Rremove mutations section until we have ready script for interactive plots
      <li><a href="#oncoprint">Mutations</a></li>
      -->
      <li><a href="#survival">Survival analysis</a></li>
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

    <!-- Exclude clustering/heatmap for now
    <div id="expression_clustering">
      <div class='description'>
        <p class='pub_det'> Unsupervised hierarchical clustering of ICGC (PACA-CA) samples expression profiles is presented as heatmap with genes and samples
        represented by columns and rows, respectively. The ICGC (PACA-CA) samples charactersitcs are also indicated on the right hand-side.
        </p>
      </div>

      <iframe class='results' scrolling='no' src='$iframe_directory/heatmap_exp_1.html'></iframe>
    </div>
    -->

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
      <select id="gea_icgc_sel"> </select>
      <button id="gea_icgc_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='gea_icgc' id='gea_icgc'></div>
      <iframe class='results' id='gea_icgc_sel_box'></iframe>
      <iframe class='results' id='gea_icgc_sel_bar'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("gea_icgc_sel", "", "", "icgc_PACA-CA")</script>
      <script>LoadAnalysis("gea_icgc_sel","gea_icgc_run","icgc","","icgc_PACA-CA_gene_expression","0")</script>
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
        <u class="note"> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
        <!-- putting gene selector -->
        <select multiple id="cea_icgc_sel"> </select>
        <br><br><br>
        <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
        <br><br>
        <textarea id='textcea_icgc_sel' rows='3' cols='80'></textarea>
        <br>
        <button id="cea_icgc_run" class="run"> Run analysis </button>
      </div>

      <!-- Loading div -->
      <div class='cea_icgc' id='cea_icgc'></div>
      <iframe class='results' id='cea_icgc_sel_hm'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("cea_icgc_sel", "", "", "icgc_PACA-CA")</script>
      <script>LoadAnalysis("cea_icgc_sel","cea_icgc_run","icgc","","icgc_PACA-CA_co_expression","1")</script>
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
      <select id="el_icgc_sel"> </select>
      <button id="el_icgc_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='el_icgc' id='el_icgc'></div>
      <iframe class='results' id='el_icgc_sel_boxel_mut'></iframe>
      <iframe class='results' id='el_icgc_sel_el_mut'></iframe>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("el_icgc_sel", "", "", "icgc_PACA-CA")</script>
      <script>LoadAnalysis("el_icgc_sel","el_icgc_run","icgc","","icgc_PACA-CA_expression_layering","1")</script>
    </div>

    <div id="copy_number_alterations">
      <div class='description'>
        <p class='pub_det'>
          An overview of DNA copy number alterations (CNA) are presented as frequency plots.
          From here, you can view the CNA specific to the dataset selected and the biological groups available.
        </p>
      </div>

      <!-- Loading div -->
      <div class='fcna_icgc' id='fcna_icgc'>
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
      <select multiple id="cna_icgc_sel"> </select>
      <br><br><br>
      <h4> ...or you can paste you gene list here (separated by any wide space character)</h4>
      <br><br>
      <textarea id='textcna_icgc_sel' rows='3' cols='80'></textarea>
      <br>
      <button id="cna_icgc_run" class="run"> Run analysis </button>
      <br><br>

      <div class='cna_icgc' id='cna_icgc'></div>

      <!-- Loading div -->
      <div class='cna_icgc' id='cna_icgc'>
        <iframe class='results' id='cna_hm' onload='resizeIframe(this)'></iframe>
      </div>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("cna_icgc_sel", "", "", "icgc_PACA-CA_cnv")</script>
      <script>LoadAnalysis("cna_icgc_sel","cna_icgc_run","icgc","","icgc_PACA-CA_gene_copy_number","1")</script>

    </div>

    <div id="survival">
      <div class='description'>
        <p class='pub_det'>
          The relationship between gene of interest and survival can be assessed.
          A univariate model is applied to the survival data and ICGC (PACA-CA) samples are assigned to risk groups
          based on the median dichotomisation of mRNA expression intensities of the selected gene.
          Relationships are presented as Kaplan-Meier plots.
        </p>
        <br><br>
        <h4> Please select a gene of interest </h4>
        <br>
        <u class=note> Just the genes present in the specific study are listed and taken into account for the analysis! </u>
        <br><br>
      </div>
      <!-- putting gene selector -->
      <select id="surv_icgc_sel"> </select>
      <button id="surv_icgc_run" class="run"> Run analysis </button>

      <!-- Loading div -->
      <div class='surv_icgc' id='surv_icgc'></div>

      <!-- loading graph container when result launched  -->
      <div class='survival_container' id='GraphContainerSURV'></div>

      <center>
        <iframe class='results' id='surv_icgc_sel_km'></iframe>
      </center>

      <!-- Calling Javascripts -->
      <script>LoadGeneSelector("surv_icgc_sel", "", "", "icgc_PACA-CA")</script>
      <script>LoadAnalysis("surv_icgc_sel","surv_icgc_run","icgc","","icgc_PACA-CA_survival","0")</script>
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
                <select multiple id='icgc_net_sel'></select>
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
                <button id="icgc_run_net" class="run"> Run analysis </button>
              </td>
            </tr>
          </table>
          <!-- load legend div -->
          <div id='net_legend' title='Network legend' style='display:none'>
            <img src='../images/net_legend.svg'
          </div>
      </div>

      <div class='icgc_net' id='icgc_net'></div>

      <!-- loading graph container when result launched -->
      <div class='network_container' id='GraphContainerNET'>
        <!-- initializing hidden value for random code (useful for changing graph later) -->
        <input type='hidden' id='random_code'/>
        <table>
          <tr>
            <h4> Speciments available in the dataset: </h4><br>
EOT;
      // loading multiple radio buttons according to the speciments into the target file
      $target_io = fopen("$result_directory/gea_target.txt", "r");
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
      <script>LoadGeneSelector('icgc_net_sel','','','icgc_PACA-CA')</script>
      <script>LoadAnalysis('icgc_net_sel','icgc_run_net','','','icgc_PACA-CA_gene_network','0')</script>
    </div>
  </div>

  <script> LoadICGCTable() </script>
  <script> LoadICGCTabs() </script>

EOT;
?>
