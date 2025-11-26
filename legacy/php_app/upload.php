<?php
// Ensure the uploads directory exists
$uploadDir = "uploads/content/";
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Handle the file upload
if (!empty($_FILES['file']['name'])) {
    $file = $_FILES['file'];
    $fileName = time() . "_" . basename($file["name"]); // Prevent duplicate names
    $filePath = $uploadDir . $fileName;

    if (move_uploaded_file($file["tmp_name"], $filePath)) {
        // Return the image URL
        echo json_encode(["location" => $filePath]);
    } else {
        echo json_encode(["error" => "File upload failed"]);
    }
} else {
    echo json_encode(["error" => "No file uploaded"]);
}
?>
