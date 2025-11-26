<?php
// db_connect.php

// Database configuration for unified schema
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');         // No password for XAMPP default setup
define('DB_NAME', 'autopredator_unified');

// Create MySQL connection using OOP style
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    die("<p>Unable to connect to the database. Please try again later.</p>");
}

// Set character set to UTF-8 (important!)
$conn->set_charset("utf8mb4");
?>
