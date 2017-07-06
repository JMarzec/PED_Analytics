<?php

  //ini_set('display_errors',1);
  //ini_set('display_startup_errors',1);
  //error_reporting(-1);

  // loading_results.php
  // report the available results for each paper, according to what has been analysed

  $pmid = $_GET["pmid"];

  // importing variables file
  include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file
  include('functions.php');

  /** * MySQL connection */
  $conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
  $conn->set_charset("utf8"); // setting the right character set

  // dynamical listing the datasets downloaded (related to the selected PMID)
  $geo_folders = glob("$absolute_root_dir/ped_backoffice/data/*_$pmid*", GLOB_ONLYDIR); // note: the Directory may vary

  // extracting just the ArrayExpress accession
  $ae_accessions = array();
  error_log("geo_folders: $ae_accessions", 0);
   foreach ($geo_folders as &$gf) {
    $ae_accessions[] = explode("_", end(explode("/", $gf)))[0];
  }

  // extracting information from PMID
  $features = "PMID, Title, Journal, Abstract, PubDate, Analysis";
  $pub_info_query = "SELECT $features";
  $pub_info_query.= " FROM $articles_table WHERE PMID=$pmid";
  $query=mysqli_query($conn, $pub_info_query) or die("Sorry, cannot perform the query");

echo "<div class=container id='literature'>
        <h1> Publication Details </h1>
      ";
  /* PRESENTING PUBLICATION DETAILS */
  while( $row=mysqli_fetch_array($query) ) {
    echo "<h4> PMID </h4> <p class='pub_det'>".$row["PMID"]."</p><br>";
    echo "<h4> Title </h4> <p class='pub_det'>".$row["Title"]."</p><br>";
    echo "<h4> Journal </h4> <p class='pub_det'>".$row["Journal"]."</p>";
    echo "<h4> Pub. Date </h4> <p class='pub_det'>".$row["PubDate"]."</p><br>";
    echo "<h4> Abstract </h4> <textarea readonly id='abstract' rows='10' cols='100'>".str_replace("&apo;","'",$row["Abstract"])."</textarea><br><br>";

    echo "<p class='pub_det'> This publication contains <b>".count($ae_accessions)."</b> datasets. Please refer to the paper for further details.</p><br>";
    echo "<center><a class='papers_link' href='https://www.ncbi.nlm.nih.gov/pubmed/".$row["PMID"]."' target='null'> Read the paper</a></center>";

    $all_performed_analyses = explode(",",$row["Analysis"]);
  }
echo "</div>
<div id='res_acc'> ";

  // We decided to put results in a one-page style, with multiple tabs to split the types of analysis
  // initializing cont
  $cont = 0;
  foreach ($ae_accessions as $ae) {
    echo "<h3>$ae</h3>";
    // initializing divs
    echo "<div class='section' id='section_$cont'>";

      /* initialising the tabs with all the performed analysis (Note: for multiple superseries,
      if not all the analysis have been produced for both, an error page will appear) */
      echo "<div id='tabs_s$cont'>
              <ul>";
      foreach ($all_performed_analyses as $pa) {
        $pa_web = str_replace(' ', '_', $pa);
        echo "  <li><a href='#$pa_web+$cont'> $pa </a></li>";
      }
      echo "  </ul>";

      // SETTING UP FOLDER NAME WHERE TO LOOK
      $result_directory = "$absolute_root_dir/ped_backoffice/data/$ae"."_"."$pmid";
      $expr_directory = $result_directory."/norm_files";
      $iframe_directory = "$relative_root_dir/ped_backoffice/data/$ae"."_"."$pmid";

      // opening connection to the target file and saving into an array
      $target_io = fopen("$result_directory/target.txt", "r");

      // initialising sections for the results
      foreach ($all_performed_analyses as $pa) {
        $pa_web = str_replace(' ', '_', $pa);
        // checking the type of analysis
        // the content of tabs is different for each analysis type

        if ($pa == "Molecular classification") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'> The PAM50 single sample predictor model
                        <sup><a href='https://www.ncbi.nlm.nih.gov/pubmed/19204204' target=null>1</a></sup>, assigns samples into intrinsic tumour types,
                        with distinct transcriptomic signatures, based on the expression of key breast cancer-specific genes.
                        These subgroups comprise the oestrogen receptor positive subtypes (Luminal A and Luminal B) and the oestrogen
                        receptor negative subtypes (Basal-like, Her2-enriched and Normal breast-like).
                        Here, we present the molecular subtype calls for all tumour samples.
                    </p>
                  </div>";

                  // checking if the file for the analysis is available
                  chdir($result_directory);
                  if (file_exists("pam50.html")) {
                    echo "<div class='pam50_container'>
                            <iframe class='results' src='$iframe_directory/pam50.html'></iframe>
                          </div>";
                  } else {
                    echo "<h3> Sorry no analyses are available </h3>";
                  }

          echo "</div>";
        } elseif ($pa == "Receptor status") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'> Gaussian finite mixture modelling is implemented to define
                        oestrogen (ER), progesterone (PR) and Her2 receptor status
                        <sup><a href='https://www.ncbi.nlm.nih.gov/pubmed/27818791' target=null>1</a></sup>.
                        Here, we present the receptor status of the samples based on the gene expression of ER, PR and Her2.
                        These classifications are used to define triple negative samples.
                    </p>
                  </div>";

                  // checking if the file for the analysis is available
                  if (file_exists("$result_directory/mclust.html")) {
                    echo "<div class='mclust_container'>
                            <iframe class='results' src='$iframe_directory/mclust.html'></iframe>
                          </div>";
                  } else {
                    echo "<h3> Sorry no analyses are available </h3>";
                  }

          echo "</div>";
        } elseif ($pa == "Tumour purity") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'> Cancer samples frequently contain a small proportion of infiltrating stromal and immune cells that might not
                        only confound the tumour signal in molecular analyses but may also have a role in tumourigenesis and progression.
                        We apply an algorithm<sup><a href='https://www.ncbi.nlm.nih.gov/pubmed/24113773' target=null>1</a></sup> that infers the tumour purity and the presence of infiltrating stromal/immune cells from gene expression data.
                        A tumour purity value between 0 and 1 is inferred from the calculated stromal score,
                        immune score and estimate score. All of these values are presented as a scatterplot,
                        with a breakdown of scores for each sample available in tabular format from the target file.
                    </p>
                  </div>";

                // checking if the file for the analysis is available
                if (file_exists("$result_directory/estimate.html")) {
                  echo "<div class='estimate_container'>
                          <iframe class='results' id='estimate' scrolling='no' src='$iframe_directory/estimate.html'></iframe>
                        </div>";

                  // loading tumor purity datatable
                  echo "<table id='Estimate$cont$pmid' class='display'>
                          <thead>
                            <tr>
                              <th>Sample name</th>
                              <th>Specimen</th>
                              <th>Tumour purity</th>
                          </thead>
                          <tfoot>
                            <tr>
                              <th>Sample name</th>
                              <th>Specimen</th>
                              <th>Tumour purity</th>
                          </tfoot>
                          <tbody>";

                  // loading data about the tumour purity
                  // removing first line
                  fgetcsv($target_io, 1000, "\t");
                  while (($target = fgetcsv($target_io, 1000, "\t")) !== FALSE) {
                    $num_fields = count($target);

                    echo "<tr>"; // opening column row
                    // selecting indexes of interface_exists
                    // 0 = Sample name, 2 = Specimen, 3 = Tumour Purity
                    $indexes = array(0,2,3);
                    foreach ($indexes as &$punt) {
                      if ($punt == 3) { // we are managing the tumour purity number, we want to round it
                        $tp = round($target[$punt]*100,2);
                        echo "<td>".$tp."</td>";
                      } else {
                        echo "<td>".$target[$punt]."</td>";
                      }
                    }
                    echo "</tr>"; // closing column row
                  }

                  // closing tumour purity table
                  echo "    </tbody>
                          </table>";

                } else {
                  echo "<h3> Sorry no analyses are available </h3>";
                }
          echo "</div>";
          // loading javascript to load DataTable tumour purity
          echo "<script> LoadEstimateDataTable(\"Estimate$cont$pmid\") </script>";
        } elseif ($pa == "PCA") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'> Principal component analyses (PCA) transforms the data into a coordinate system and presenting it as an orthogonal projection.
                        This reduces the dimensionality of the data, allowing for the global structure and key “components” of variation of the data to be viewed.
                        Each point represents the orientation of a sample in the transcriptional space projected on the PCA,
                        with different colours representing the biological group of the sample.
                    </p>
                  </div>";

                  // NB: Multiple PCA analyses can be present in the results (different expression files)
                  // for this reason we list all the PCAs
                  chdir($result_directory);
                  $pca_files = glob("pca*.html");
                  if (count($pca_files) > 0) {
                    foreach ($pca_files as &$pca_file) {
                      echo "<div class='pca_container'>
                              <iframe class='results' scrolling='no' src='$iframe_directory/$pca_file'></iframe>
                            </div>";
                    }
                  } else {
                     echo "<h3> Sorry no analyses are available </h3>";
                  }

          echo "</div>";
        } elseif ($pa == "Gene expression") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'>
                      The expression profile of selected gene(s) across comparative groups are presented as both summarised and a
                      sample views (boxplots and barplots, respectively).
                    </p>
                    <br><br>
                    <h4> Please select a gene of interest </h4>
                    <br>
                  </div>";

          // loading autocomplete text
          echo "<select id=\"ep$cont\"></select>
                <button id=\"runep$cont\"> Run analysis </button>";

          // loading graph container when result launched
          echo "<div class='expression_profile_container' id='GraphContainerEP_$pa_web'></div>";
          echo "<iframe class='results' id='ep$cont"."_box'></iframe>";
          echo "<iframe class='results' id='ep$cont"."_bar'></iframe>";

          // loading javascripts
          echo "<script>LoadGeneSelector(\"ep$cont\",\"$ae\",\"$pmid\", \"\")</script>";
          echo "<script>LoadAnalysis(\"ep$cont\",\"runep$cont\",\"$ae\",\"$pmid\",\"gene_expression\",\"$cont\")</script>";

        echo "</div>";

      } elseif ($pa == "Correlations") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'>
                      We offer users the opportunity to identify genes that are co-expressed with their gene(s) of interest.
                      This value is calculated using the Pearson Product Moment Correlation Coefficient (PMCC) value.
                      Correlations for the genes specified by the user are presented in a heatmap.
                    </p>
                    <br><br>
                    <h4> Please select at least 2 genes of interest (max 50 genes)</h4>
                    <br>
                  </div>";

            // loading autocomplete text
            echo "<select multiple id=\"cea$cont\">
                  </select>
                  <button id=\"runcea$cont\"> Run analysis </button>";

            // loading graph container when result launched
            echo "<div class='coexpression_container' id='GraphContainerCEA_$pa_web'></div>";
            echo "<iframe class='results' id='cea$cont"."_hm'></iframe>";

            // loading javascripts
            // NB: Rplots start counting from 1 -- adding 1 to php $cont
            echo "<script>LoadGeneSelector(\"cea$cont\",\"$ae\",\"$pmid\", \"\")</script>";
            echo "<script>LoadAnalysis(\"cea$cont\",\"runcea$cont\",\"$ae\",\"$pmid\",\"co_expression\",\"$cont\")</script>";

          echo "</div>";

        } elseif ($pa == "Survival analysis") {
          echo "<div id='$pa_web+$cont'>
                  <div class='description'>
                    <p class='pub_det'>
                      The relationship between gene(s) of interest and survival can be assessed.
                      A univariate model is applied to the survival data and samples are assigned to risk groups
                      based on the median dichotomisation of mRNA expression intensities of the selected gene(s).
                      Relationships are presented as Kaplan Meier plots.
                    </p>
                    <br><br>
                    <h4> Please select a gene of interest </h4>
                    <br>
                  </div>";

                  // loading autocomplete text
                  echo "<select id=\"surv$cont\">
                        </select>
                        <button id=\"runsurv$cont\"> Run analysis </button>";

                  // loading graph container when result launched
                  echo "<div class='survival_container' id='GraphContainerSURV_$pa_web'></div>";

                  // checking if the file for the analysis is available
                  if (file_exists("$result_directory/pca_bp_1.html")) {
                  //  echo "<center>
                  //          <img src='$iframe_directory/KM_subtype.png'></iframe>
                  //        </center>";
						echo "<iframe class='results' id='surv$cont"."_hm'></iframe>";
						
                          // loading javascripts
                          // NB: Rplots start counting from 1 -- adding 1 to php $cont
                          $plot_cont = $cont + 1;
                          echo "<script>LoadGeneSelector(\"surv$cont\",\"$ae\",\"$pmid\", \"\")</script>";
                          echo "<script>LoadAnalysis(\"surv$cont\",\"runsurv$cont\",\"$ae\",\"$pmid\",\"survival\",\"$plot_cont\")</script>";


                  } else {
                    echo "<h3> Sorry no analyses are available </h3>";
                  }

        echo "</div>";
      echo "
      </div>";
        }
            echo "<script>LoadResultTabs($cont)</script>";
      }
      // Loading Javascript Functions
      
      $cont++;
      // load javascript accordion
      echo "<script>LoadResultAcc()</script>";
echo "</div>";
  }
echo "</div>";

?>
