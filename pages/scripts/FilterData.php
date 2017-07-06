<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file

// getting mesh term id to retrieve
$mesh_id = $_GET["mesh_id"];
 
/**
 * MySQL connection
 */
$conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
$conn->set_charset("utf8"); // setting the right character set

// storing  request (ie, get/post) global array to a variable  
$requestData= $_REQUEST;

$columns = array( 
// datatable column index  => database column name
	0 =>'PMID', 
	1 => 'Title',
	2=> 'Journal',
    3=> 'PubDate',
    4=> 'Ranking',
	5=> 'analysis',
);

// getting total number records without any search
$sql = "SELECT $articles_table.PMID, $articles_table.Title, $articles_table.Journal, $articles_table.PubDate, $articles_table.Ranking, $articles_table.analysis";
$sql.=" FROM $articles_table, $keywords_table, $articles_keywords_table";
$sql.=" WHERE $keywords_table.ID=$mesh_id AND $articles_keywords_table.KW=$keywords_table.ID AND $articles_table.PMID=$articles_keywords_table.PMID";

//echo $sql;
$query=mysqli_query($conn, $sql) or die("Sorry, cannot perform the query");
// getting number total retrieve data
$totalData = mysqli_num_rows($query);
// here we have putted the filter in the query so the number of filtered data correspond to the number of totalData
$totalFiltered = $totalData;

// preparing results
$data = array();
while( $row=mysqli_fetch_array($query) ) {  // preparing an array
	$nestedData=array(); 

	$nestedData[] = $row["PMID"];
	$nestedData[] = $row["Title"];
	$nestedData[] = $row["Journal"];
    $nestedData[] = $row["PubDate"];
    $nestedData[] = $row["Ranking"];
	$nestedData[] = $row["analysis"];
	
	$data[] = $nestedData;
}

$json_data = array(
			"draw"            => intval( $requestData['draw'] ),   // for every request/draw by clientside , they send a number as a parameter, when they recieve a response/data they first check the draw number, so we are sending same number in draw. 
			"recordsTotal"    => intval( $totalData ),  // total number of records
			"recordsFiltered" => intval( $totalFiltered ), // total number of records after searching, if there is no searching then totalFiltered = totalData
			"data"            => $data   // total data array
			);

echo json_encode($json_data);  // send data as json format

?>