<?php

/* Vars for Research Portal resource *
 * Coder: Stefano Pirro'
 * Institution: Barts Cancer Institute
 * Details: This page lists all the variables necessary for mySQL database connection and other*/

// connection vars to mySQL database for PED analytics
$bob_mysql_address='localhost';
$bob_mysql_username='snp';
$bob_mysql_password='snp76qmul'; // in next release, the password will be encrypted
$bob_mysql_database='ped_bioinf_portal';

// tables
$articles_table = "Articles";
$keywords_table = "Keywords";
$articles_keywords_table = "Articles_Keywords";
$ccle_table = "ccle";
$tcga_table = "tcga";

// initialising directories
$relative_root_dir = "http://".$_SERVER['SERVER_NAME']."/";
$absolute_root_dir = $_SERVER['DOCUMENT_ROOT'];

?>
