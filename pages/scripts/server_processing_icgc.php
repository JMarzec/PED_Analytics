<?php

// importing variables file
include('vars.php'); // from this point it's possible to use the variables present inside 'vars.php' file

// Features to search
$features = "Project, Cancer_type, Samples_expression, Samples_survival, Samples_copy_number, Samples_mutation";

/**
 * MySQL connection
 */
$conn = mysqli_connect($bob_mysql_address, $bob_mysql_username, $bob_mysql_password, $bob_mysql_database) or die("Connection failed: " . mysqli_connect_error());
$conn->set_charset("utf8"); // setting the right character set

// storing  request (ie, get/post) global array to a variable
$requestData= $_REQUEST;

$columns = array(
// datatable column index  => database column name
	0 =>'Project',
	1 =>'Cancer_type',
	2 =>'Samples_expression',
	3=> 'Samples_survival',
	4=> 'Samples_copy_number',
    5=> 'Samples_mutation',
);

// getting total number records without any search
$sql = "SELECT $features";
$sql.=" FROM $platforms_table";

$query=mysqli_query($conn, $sql) or die("Sorry, cannot perform the query");
$totalData = mysqli_num_rows($query);
$totalFiltered = $totalData;  // when there is no search parameter then total number rows = total number filtered rows.

// preparing results
$data = array();
while( $row=mysqli_fetch_array($query) ) {  // preparing an array
	$nestedData=array();

	$nestedData[] = $row["Project"];
	$nestedData[] = $row["Cancer_type"];
	$nestedData[] = $row["Samples_expression"];
	$nestedData[] = $row["Samples_survival"];
	$nestedData[] = $row["Samples_copy_number"];
  	$nestedData[] = $row["Samples_mutation"];

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
