<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/repository.php';
require_once __DIR__ . '/../views/layout.php';

$page_title = $page_title ?? 'Autopredator - Car Research Platform';
$page_description = $page_description ?? 'Discover cars, compare variants, and find the right model for you.';
$current_user = auth_current_user();

if (!headers_sent()) {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('Referrer-Policy: strict-origin-when-cross-origin');
}

$suggestions = [];
try {
    $brands = get_all_manufacturers();
    foreach ($brands as $man) {
        if (!empty($man['name'])) {
            $suggestions[] = $man['name'];
        }
    }
    $models = [];
    if (function_exists('car_service')) {
        foreach ($brands as $man) {
            foreach (car_service()->getModelsByBrand($man['name']) as $m) {
                $models[] = $m['model'] ?? '';
            }
        }
    }
    $suggestions = array_values(array_unique(array_filter(array_merge($suggestions, $models))));
} catch (\Throwable $e) {
    $suggestions = [];
}

render_layout_start($page_title, $page_description, ['suggestions' => $suggestions]);
