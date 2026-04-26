<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../app/Repositories/VariantRepository.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $variantRepo = new VariantRepository();

    // Parse query parameters
    $query = trim($_GET['q'] ?? '');
    $brand = trim($_GET['brand'] ?? '');
    $fuel = trim($_GET['fuel'] ?? '');
    $transmission = trim($_GET['transmission'] ?? '');
    $minPrice = isset($_GET['minPrice']) ? (float) $_GET['minPrice'] : null;
    $maxPrice = isset($_GET['maxPrice']) ? (float) $_GET['maxPrice'] : null;

    $variants = $variantRepo->searchVariants([
        'query' => $query,
        'brand' => $brand,
        'fuel' => $fuel,
        'transmission' => $transmission,
        'minPrice' => $minPrice,
        'maxPrice' => $maxPrice,
    ]);

    // Format response
    $response = array_map(function ($variant) {
        return [
            'id' => $variant['id'],
            'name' => $variant['name'],
            'slug' => $variant['slug'],
            'model_name' => $variant['model_name'],
            'brand_name' => $variant['brand_name'],
            'fuel_type' => $variant['fuel_type'],
            'transmission_type' => $variant['transmission_type'],
            'price' => $variant['price'] ? [
                'amount' => $variant['price'],
                'currency' => $variant['currency'] ?? 'INR',
            ] : null,
            'thumbnail_url' => $variant['thumbnail_url'],
        ];
    }, $variants);

    http_response_code(200);
    echo json_encode($response);

} catch (Exception $e) {
    error_log('API Error in search.php: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
