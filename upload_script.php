<?php
// Database connection details (replace with your actual credentials)
$servername = "your_servername";
$username = "your_username";
$password = "your_password";
$dbname = "your_database_name";
// File moved to modules/upload_script.php
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from the form
$category = $_POST['category'];
$subcategory = $_POST['subcategory'];
$feature = $_POST['feature'];

// Prepare and execute the SQL query
$sql = "INSERT INTO CarFeatures (Category, Subcategory, Feature) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $category, $subcategory, $feature); // "sss" indicates three string parameters

if ($stmt->execute()) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$stmt->close();
$conn->close();
?>