<?php
include 'db_connect.php';
if ($conn->connect_error) {
    echo 'Connection failed: ' . $conn->connect_error;
} else {
    echo 'Connected successfully';
    $conn->close();
}
?>
