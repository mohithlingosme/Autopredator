<?php
// api/index.php - Main API entry point
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config.php';
require_once '../includes/functions.php';

// Get the request method and path
$method = $_SERVER['REQUEST_METHOD'];
$request = $_SERVER['REQUEST_URI'];

// Remove query string and get path segments
$path = parse_url($request, PHP_URL_PATH);
$path = str_replace('/api/', '', $path);
$segments = explode('/', trim($path, '/'));

// Route to appropriate handler
try {
    switch ($segments[0]) {
        case 'vehicles':
            require_once 'vehicles.php';
            handleVehicles($method, $segments);
            break;
        case 'blogs':
            require_once 'blogs.php';
            handleBlogs($method, $segments);
            break;
        case 'insurance':
            require_once 'insurance.php';
            handleInsurance($method, $segments);
            break;
        default:
            http_response_code(404);
            echo json_encode(['error' => 'API endpoint not found']);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error', 'message' => $e->getMessage()]);
}
?>
