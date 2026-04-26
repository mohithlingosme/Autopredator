<?php
declare(strict_types=1);

// Health check endpoint
header('Content-Type: application/json');

// Check database connection
$dbHealthy = false;
try {
    require_once 'includes/db.php';
    $pdo = get_db();
    $pdo->query('SELECT 1');
    $dbHealthy = true;
} catch (Exception $e) {
    // Log error
}

$status = $dbHealthy ? 'healthy' : 'unhealthy';
$code = $dbHealthy ? 200 : 503;

http_response_code($code);

echo json_encode([
    'status' => $status,
    'timestamp' => date('c'),
    'checks' => [
        'database' => $dbHealthy ? 'ok' : 'error'
    ]
]);
