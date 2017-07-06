<?php

/* Index page for the BOB portal (Breast Now Bioinformatics) *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: This is the main page for all the bioinformatics analysis inside the Research Portal */

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'var.php' file

// https://cdn.datatables.net/v/ju/pdfmake-0.1.27/dt-1.10.15/af-2.2.0/b-1.3.1/b-colvis-1.3.1/b-flash-1.3.1/b-html5-1.3.1/b-print-1.3.1/cr-1.3.3/fc-3.2.2/fh-3.1.2/kt-2.2.1/r-2.1.1/rg-1.0.0/rr-1.2.0/sc-1.4.2/se-1.2.2/datatables.min.css"/>

// Header and body sections
echo <<< EOT
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>BOB portal -- PED Data Portal</title>

            <!-- CSS LINKS -->
            <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.css">
            <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.15/css/jquery.dataTables.css"/>
            <link rel="stylesheet" href="../styles/easy-autocomplete.css">
                <!-- SELECT2 PLUGIN -->
                <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />

            <link rel="stylesheet" type="text/css" href="../styles/bob.css">

            <!-- JS LINKS -->
            <!-- Loading Jquery -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.js"></script>
            <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.15/js/jquery.dataTables.js"></script>

            <!-- SELECT2 PLUGIN -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.full.js"></script>

            <!-- Loading personal scripts -->
            <script type="text/javascript" src="../js/jquery.dataTables.yadcf.js"></script>
            <script type="text/javascript" src="../js/jquery.easy-autocomplete.js"></script>
            <script type="text/javascript" src="../js/jquery-ui.accordion.multiple.js"></script>
            <script type="text/javascript" src="../js/jquery.scrollIntoView.js"></script>
            <script type="text/javascript" src="../js/jquery.ui.autocomplete.scroll.js"></script>
            <script type="text/javascript" src="../js/bob.js"></script>
    </head>

    <body>
        <!-- ---------------------- -->
        <!-- NAVIGATION MENU -->
        <div id="menu">
            <table id="menu_cont">
                <tr>
                    <td style='width:70%'><img id="front_logo_small" src="../images/ped_logo.png"/></td>
                    <td style='width:30%'>
                        <a href="" class='menu_btn' id="home" title="Return to Home">Home</a>
                        <a href="" class='menu_btn' id="contact" title="Contact us">Contact us</a>
                        <a href="" class='menu_btn' id="doc" title="Read the documentation">Documentation</a>
                    </td>
                </tr>
            </table>
        </div>
        <div class="container" id="source"> </div>

        <!-- ---------------------------------------- -->
        <script> LoadHomePage() </script>
        <script> LoadMenuSelector() </script>
    </body>
EOT;

// Footer section
echo <<< EOT

</html>
EOT;

// Google Analytics section (filled once the website is completed)
//
//

?>
