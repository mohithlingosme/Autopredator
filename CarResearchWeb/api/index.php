<?php
declare(strict_types=1);

/**
 * API Router for CarResearchWeb
 * Routes requests to appropriate controllers based on path and method.
 */

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../app/Support/Autoload.php';

define('APP_DEBUG', false); // Set to true for development

// Set JSON headers
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

// Parse request
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/api/', '', $path); // Remove /api/ prefix
$pathParts = explode('/', trim($path, '/'));
$endpoint = $pathParts[0] ?? '';
$param = $pathParts[1] ?? '';

// Rate limiting (apply to abuse-prone endpoints)
$rateLimiter = new \App\Support\RateLimiter();
$ip = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';

if (in_array($endpoint, ['search', 'leads', 'admin'])) {
    $limits = [
        'search' => ['req' => 60, 'window' => 60], // 60 req/min
        'leads' => ['req' => 10, 'window' => 600], // 10 req/10min
        'admin' => ['req' => 10, 'window' => 600], // 10 req/10min
    ];
    if (!$rateLimiter->check($ip, $endpoint, $limits[$endpoint]['req'], $limits[$endpoint]['window'])) {
        http_response_code(429);
        echo json_encode(['ok' => false, 'error' => ['code' => 'RATE_LIMIT_EXCEEDED', 'message' => 'Too many requests']]);
        exit;
    }
}

// Route to controllers
try {
    switch ($endpoint) {
        case 'brands':
            $controller = new \App\Controllers\BrandsController(repo());
            $controller->handle($method, $param);
            break;
        case 'models':
            $controller = new \App\Controllers\ModelsController(repo());
            $controller->handle($method, $param);
            break;
        case 'variants':
            $controller = new \App\Controllers\VariantsController(repo());
            $controller->handle($method, $param);
            break;
        case 'search':
            $controller = new \App\Controllers\SearchController(repo());
            $controller->handle($method);
            break;
        case 'compare':
            $controller = new \App\Controllers\CompareController(repo());
            $controller->handle($method);
            break;
        case 'shortlist':
            $controller = new \App\Controllers\ShortlistController();
            $controller->handle($method, $param);
            break;
        case 'leads':
            $controller = new \App\Controllers\LeadsController();
            $controller->handle($method);
            break;
        case 'admin':
            $auth = new \App\Support\AdminAuth();
            if (!$auth->check()) {
                http_response_code(401);
                echo json_encode(['ok' => false, 'error' => ['code' => 'UNAUTHORIZED', 'message' => 'Admin authentication required']]);
                exit;
            }
            $controller = new \App\Controllers\AdminController();
            $controller->handle($method, $param);
            break;
        case 'filters':
            $controller = new \App\Controllers\FiltersController(repo());
            $controller->handle($method);
            break;
        case 'health':
            try {
                $pdo = get_db();
                $dbOk = $pdo->query('SELECT 1')->fetchColumn() == 1;
                $version = $pdo->query('SELECT VERSION()')->fetchColumn();
                echo json_encode([
                    'ok' => true,
                    'data' => [
                        'db' => $dbOk,
                        'db_name' => DB_NAME,
                        'version' => $version,
                    ],
                ]);
            } catch (Throwable $e) {
                http_response_code(500);
                echo json_encode(['ok' => false, 'error' => ['code' => 'DB_UNAVAILABLE', 'message' => $e->getMessage()]]);
            }
            break;
        default:
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Endpoint not found']]);
            break;
    }
} catch (Throwable $e) {
    error_log($e->getMessage());
    http_response_code(500);
    $debug = defined('APP_DEBUG') && APP_DEBUG ? ['debug' => $e->getMessage()] : [];
    echo json_encode(['ok' => false, 'error' => ['code' => 'INTERNAL_ERROR', 'message' => 'An error occurred']] + $debug);
}
