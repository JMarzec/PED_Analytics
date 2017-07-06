<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file

// Features to search
$features = "name, target, age, years_smoked, alcohol_history, gender, tumor_stage, tnm_staging, histologic_grade";

/**
 * MySQL connection
 */
$conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
$conn->set_charset("utf8"); // setting the right character set

// storing  request (ie, get/post) global array to a variable
$requestData= $_REQUEST;

$columns = array(
// datatable column index  => database column name
	0 =>'name',
	1 => 'target',
	2 => 'age',
	3=> 'years_smoked',
  4=> 'alcohol_history',
	5=> 'gender',
  6=> 'ethnicity',
	7 => 'tnm_staging',
	8 => 'histologic_grade',
);

// getting total number records without any search
$sql = "SELECT $features";
$sql.=" FROM $tcga_table";

$query=mysqli_query($conn, $sql) or die("Sorry, cannot perform the query");
$totalData = mysqli_num_rows($query);
$totalFiltered = $totalData;  // when there is no search parameter then total number rows = total number filtered rows.

// preparing results
$data = array();
while( $row=mysqli_fetch_array($query) ) {  // preparing an array
	$nestedData=array();

	$nestedData[] = $row["name"];
	$nestedData[] = $row["target"];
	$nestedData[] = $row["age"];
	$nestedData[] = $row["years_smoked"];
  $nestedData[] = $row["alcohol_history"];
	$nestedData[] = $row["gender"];
  	$nestedData[] = $row["tumor_stage"];
	$nestedData[] = $row["tnm_staging"];
	$nestedData[] = $row["histologic_grade"];

	$data[] = $nestedData;
}

$json_data = array(
			"draw"            => intval( $requestData['draw'] ),   // for every request/draw by clientside , they send a number as a parameter, when they recieve a response/data they first check the draw number, so we are sending same number in draw.
			"recordsTotal"    => intval( $totalData ),  // total number of records
			"recordsFiltered" => intval( $totalFiltered ), // total number of records after searching, if there is no searching then totalFiltered = totalData
			"data"            => $data   // total data array
			);

echo json_encode($json_data);  // send data as json format
//echo json_last_error_msg();

?>
