<?php
// Lightweight proxy that forwards brochure PDFs to the internal FastAPI extractor.

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Method not allowed. Use POST with file upload.']);
    exit;
}

if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Missing or invalid file upload.']);
    exit;
}

$file = $_FILES['file'];
$tmpPath = $file['tmp_name'];
$filename = $file['name'] ?? 'brochure.pdf';

if (!is_readable($tmpPath)) {
    http_response_code(400);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Uploaded file is not readable.']);
    exit;
}

$curlFile = new CURLFile($tmpPath, mime_content_type($tmpPath) ?: 'application/pdf', $filename);

$ch = curl_init('http://localhost:8000/extract-specs');
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POSTFIELDS => ['file' => $curlFile],
    CURLOPT_TIMEOUT => 60,
]);

$responseBody = curl_exec($ch);
$curlError = curl_error($ch);
$statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE) ?: 500;
curl_close($ch);

header('Content-Type: application/json');

if ($responseBody === false) {
    http_response_code(502);
    echo json_encode(['error' => 'Extraction service unreachable', 'details' => $curlError]);
    exit;
}

// Forward status code and body as-is to the client.
http_response_code($statusCode);
echo $responseBody;
