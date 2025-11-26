<?php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'autopredator_unified');

function fetchAllCarData() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) die("Connection failed: " . $conn->connect_error);

    $query = "SELECT Make, Model, Variant, Ex_Showroom_Price FROM carslist WHERE Ex_Showroom_Price > 0";
    $result = $conn->query($query);

    $cars = [];
    while ($row = $result->fetch_assoc()) {
        $row['Ex_Showroom_Price'] = (int) $row['Ex_Showroom_Price'];
        $cars[] = $row;
    }

    $conn->close();
    return $cars;
}
