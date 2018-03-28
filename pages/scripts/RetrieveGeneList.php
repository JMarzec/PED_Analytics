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
  $result_directory = "$absolute_root_dir/ped_backoffice/data/ccle/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage
} elseif ($type_analysis == "ccle_cnv") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/ccle/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_cn.txt"); // in this case the "cn_chr_pos.csv" file is too much big to manage
} elseif ($type_analysis == "el_ccle") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/ccle/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp_cn.txt"); // in this case the "cn_chr_pos.csv" file is too much big to manage
} elseif ($type_analysis == "tcga") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/tcga/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp.txt"); // in this case the "gene_exp.csv" file is too much big to manage
} elseif ($type_analysis == "el_tcga") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/tcga/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_exp_cn_binary.txt"); // in this case the "cn_binary_chr_pos.csv" file is too much big to manage
} elseif ($type_analysis == "tcga_cnv") {
  $result_directory = "$absolute_root_dir/ped_backoffice/data/tcga/norm_files/";
  chdir($result_directory);
  $expr_files = glob("gene_list_cn_binary.txt"); // in this case the "cn_binary_chr_pos.csv" file is too much big to manage
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
