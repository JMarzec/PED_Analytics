<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file
include('functions.php');

// initialising vars called from ajax
$TypeAnalysis = $_GET["TypeAnalysis"];
$ArrayExpressCode = $_GET["ArrayExpressCode"];
$pmid = $_GET["PMID"];
$genes = $_GET["Genes"];
$unique_id = $_GET["rc"];

$exec_error_flag = 0; // error flag switched off by default

// *** File variables *** //
$result_directory = "$absolute_root_dir/ped_backoffice/data/$ArrayExpressCode"."_"."$pmid";
$target_file = "$result_directory/target.txt";
$tmp_dir = "$absolute_root_dir/ped_backoffice/tmp";

// checking the presence of multiple expression files inside the result Directory
$results_files = glob("$result_directory/norm_files/*.genename.csv");
$results_files_string = '';
if (count($results_files) > 0) {
  foreach ($results_files as &$rf) {
    $results_files_string .= $rf.",";
  }
}
// removing last comma from the results_files simplexml_load_string
$results_files_string = substr($results_files_string, 0, -1);

if ($TypeAnalysis == "gene_expression") {
  // *** Gene Expression Analyses *** //
  // launching Rscript for the analysis...
  error_log("Rscript LiveGeneExpression.R --exp_file $results_files_string --target $target_file --colouring \"Target\" --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output,0);
  system("Rscript LiveGeneExpression.R --exp_file $results_files_string --target $target_file --colouring \"Target\" --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);

} elseif ($TypeAnalysis == "co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  system("Rscript LiveCoExpression.R --exp_file $results_files_string --target $target_file --genes \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);

} elseif ($TypeAnalysis == "survival") {
  // *** Survival Analyses *** //
  // launching Rscript for the analysis...
  error_log("Rscript LiveSurvivalGene.R --exp_file $results_files_string --target $target_file --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", 0);
  system("Rscript LiveSurvivalGene.R --exp_file $results_files_string --target $target_file --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
} elseif ($TypeAnalysis == "ccle_gene_expression") {
  // *** Gene Expression Analyses for CCLE *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/ped_backoffice/data/ccle/gene_exp.csv";
  $target_file = "$absolute_root_dir/ped_backoffice/data/ccle/gea_target.txt";
  error_log("Rscript LiveGeneExpression.R --exp_file $expr_file --target $target_file --colouring \"Target\" --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", 0);
  system("Rscript LiveGeneExpression.R --exp_file $expr_file --target $target_file --colouring \"Target\" --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
} elseif ($TypeAnalysis == "ccle_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/ped_backoffice/data/ccle/gene_exp.csv";
  $target_file = "$absolute_root_dir/ped_backoffice/data/ccle/gea_target.txt";
  system("Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
} elseif ($TypeAnalysis == "ccle_expression_layering") {
  // *** Expression Layering Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/ped_backoffice/data/ccle/gene_exp.csv";
  $cn_file = "$absolute_root_dir/ped_backoffice/data/ccle/cn.csv";
  $target_file = "$absolute_root_dir/ped_backoffice/data/ccle/cn_target.txt";
  $mut_file = "$absolute_root_dir/ped_backoffice/data/ccle/mut.csv";
  system("Rscript LiveExprCN.R --exp_file $expr_file --cn_file $cn_file --target $target_file --colouring \"Target\" --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
  system("Rscript LiveExprCNMut.R --exp_file $expr_file --cn_file $cn_file --mut_file $mut_file --target $target_file --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
} elseif ($TypeAnalysis == "tcga_gene_expression") {
  // *** Gene Expression Analyses for CCLE *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/ped_backoffice/data/tcga/gene_exp.csv";
  $target_file = "$absolute_root_dir/ped_backoffice/data/tcga/gea_target.txt";
  system("Rscript LiveGeneExpression.R --exp_file $expr_file --target $target_file --colouring \"definition\" --gene \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
} elseif ($TypeAnalysis == "tcga_co_expression") {
  // *** Co-expression Analyses *** //
  // launching Rscript for the analysis...
  $expr_file = "$absolute_root_dir/ped_backoffice/data/tcga/gene_exp.csv";
  $target_file = "$absolute_root_dir/ped_backoffice/data/tcga/gea_target.txt";
  system("Rscript LiveCoExpression.R --exp_file $expr_file --target $target_file --genes \"$genes\" --dir $tmp_dir --hexcode \"$unique_id\" 2>&1", $output);
}
