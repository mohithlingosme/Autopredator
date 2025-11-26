<?php
// db_init.php - Script to initialize the unified database schema

// Database configuration for unified DB
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', ''); // No password for XAMPP default
define('DB_NAME', 'autopredator_unified');

// Create MySQL connection
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create database if it doesn't exist
$sql = "CREATE DATABASE IF NOT EXISTS " . DB_NAME . " CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
if ($conn->query($sql) === TRUE) {
    echo "Database 'autopredator_unified' created or already exists.<br>";
} else {
    echo "Error creating database: " . $conn->error . "<br>";
}

// Select the database
$conn->select_db(DB_NAME);

// Read and execute the merged_schema.sql file
$schemaFile = 'merged_schema.sql';
if (file_exists($schemaFile)) {
    $sql = file_get_contents($schemaFile);
    // Split into individual statements
    $statements = array_filter(array_map('trim', explode(';', $sql)));
    foreach ($statements as $statement) {
        if (!empty($statement)) {
            if ($conn->query($statement) === TRUE) {
                echo "Executed: " . substr($statement, 0, 50) . "...<br>";
            } else {
                echo "Error executing statement: " . $conn->error . "<br>";
            }
        }
    }
    echo "Schema initialization completed.<br>";
} else {
    echo "Error: merged_schema.sql file not found.<br>";
}

// Close connection
$conn->close();
?>
