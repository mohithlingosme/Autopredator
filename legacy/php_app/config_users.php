<?php
// config_users.php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "autopredator_unified"; // unified DB

$userConn = new mysqli($servername, $username, $password, $dbname);

if ($userConn->connect_error) {
    die("Connection failed: " . $userConn->connect_error);
}

$userConn->set_charset("utf8mb4");
?>
