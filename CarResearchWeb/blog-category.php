<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/app/Support/Autoload.php';

// Get category slug from URL
$categorySlug = $_GET['slug'] ?? '';

if (!$categorySlug) {
    http_response_code(404);
    include __DIR__ . '/views/errors/404.php';
    exit;
}

// Initialize content service
$contentRepo = new \App\Repositories\ContentRepository();
$contentService = new \App\Services\ContentService($contentRepo);
$blogController = new \App\Controllers\BlogController($contentService);

// Handle the request
$blogController->category($categorySlug);
?>
