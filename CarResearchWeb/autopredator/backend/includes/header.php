<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/seo_helpers.php';
require_once __DIR__ . '/structured_data.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/bootstrap.php';
require_once __DIR__ . '/../views/layout.php';

$page_title = $page_title ?? 'Autopredator - Car Research Platform';
$page_description = $page_description ?? 'Discover cars, compare variants, and find the right model for you.';
$current_user = auth_current_user();

if (!headers_sent()) {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('Referrer-Policy: strict-origin-when-cross-origin');
}

$suggestions = [
    'brands' => [],
    'models' => [],
    'variants' => [],
    'body_types' => [],
    'fuel_types' => []
];
try {
    $brands = get_all_manufacturers();
    foreach ($brands as $man) {
        if (!empty($man['name'])) {
            $suggestions['brands'][] = $man['name'];
        }
    }
    if (function_exists('car_service')) {
        foreach ($brands as $man) {
            foreach (car_service()->getModelsByBrand($man['name']) as $m) {
                $modelName = $m['model'] ?? '';
                if (!empty($modelName)) {
                    $suggestions['models'][] = $modelName;
                }
            }
        }
    }
    // Get variants, body types, fuel types from repository
    $allVariants = [];
    if (function_exists('car_service')) {
        foreach ($brands as $man) {
            foreach (car_service()->getModelsByBrand($man['name']) as $m) {
                foreach ($m['variants'] ?? [] as $variant) {
                    $allVariants[] = array_merge($variant, [
                        'brand' => $man['name'],
                        'model' => $m['model'] ?? '',
                    ]);
                }
            }
        }
    }
    foreach ($allVariants as $variant) {
        if (!empty($variant['name'])) {
            $suggestions['variants'][] = $variant['name'];
        }
        if (!empty($variant['segment'])) {
            $suggestions['body_types'][] = $variant['segment'];
        }
        if (!empty($variant['fuel_type'])) {
            $suggestions['fuel_types'][] = $variant['fuel_type'];
        }
    }
    // Unique and filter
    foreach ($suggestions as $key => $list) {
        $suggestions[$key] = array_values(array_unique(array_filter($list)));
    }
} catch (\Throwable $e) {
    $suggestions = [
        'brands' => [],
        'models' => [],
        'variants' => [],
        'body_types' => [],
        'fuel_types' => []
    ];
}

render_layout_start($page_title, $page_description, ['suggestions' => $suggestions]);
