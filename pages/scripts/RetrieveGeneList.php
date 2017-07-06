<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file
include('functions.php');

$ae = $_GET["ae"];
$pmid = $_GET["pmid"];
$type_analysis = $_GET["type_analysis"];
$query = strtoupper($_GET["q"]); // query for the search field

// retrieving all the gene expression matrices inside the result directory
if ($type_analysis == "ccle") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/ccle/";
  chdir($result_directory);
  $expr_files = glob("gene_exp.csv");
} elseif ($type_analysis == "tcga") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/tcga/";
  chdir($result_directory);
  $expr_files = glob("gene_list.txt"); // in this case the "gene_exp.csv" file is too much big to manage
} else {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/$ae"."_"."$pmid/norm_files/";
  chdir($result_directory);
  $expr_files = glob("*.genename.csv");
}

// putting all the found genes inside an array
$GeneContainer = array();
foreach ($expr_files as &$ef) {
  $GeneContainer[] = retrieveGeneList($ef);
}

$GeneContainer = array_unique(array_flatten_recursive($GeneContainer));

$data = array();

foreach ($GeneContainer as &$g) {
  if (strpos($g, $query) !== false) {
    $nestedData["id"] = $g;
    $nestedData["text"] = $g;

    $data[] = $nestedData;
  }
}

echo json_encode($data);
