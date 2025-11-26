<?php
// Car DB Connection (unified)
$host = "localhost";
$user = "root";
$password = "";
$database = "autopredator_unified";

$carConn = new mysqli($host, $user, $password, $database);

if ($carConn->connect_error) {
    die("Car DB connection failed: " . $carConn->connect_error);
}
?>
