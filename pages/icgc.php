<?php

// importing variables file
include('scripts/vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// importing variables
$iframe_directory = $relative_root_dir."pixdb_backoffice/data/icgc/";
$result_directory = "$absolute_root_dir/pixdb_backoffice/data/icgc/";

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
        
<div class="container" id="main"></div>
<div class="container" id="loading"></div>
<div class="container" id="results"></div>


<script> LoadICGCTable() </script>
<script> LoadICGCSelector() </script>

EOT;
?>
