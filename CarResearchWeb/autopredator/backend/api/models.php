<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../app/Repositories/BrandRepository.php';
require_once __DIR__ . '/../app/Repositories/ModelRepository.php';

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

$brandSlug = $_GET['brandSlug'] ?? '';

if (empty($brandSlug)) {
    http_response_code(400);
    echo json_encode(['error' => 'brandSlug parameter is required']);
    exit;
}

try {
    $brandRepo = new BrandRepository();
    $modelRepo = new ModelRepository();

    $brand = $brandRepo->findBySlug($brandSlug);
    if (!$brand) {
        http_response_code(404);
        echo json_encode(['error' => 'Brand not found']);
        exit;
    }

    $models = $modelRepo->getModelsByBrandId((int) $brand['id']);

    // Format response
    $response = array_map(function ($model) {
        return [
            'id' => $model['id'],
            'name' => $model['name'],
            'slug' => $model['slug'],
            'brand_id' => $model['brand_id'],
            'launch_year' => $model['launch_year'],
        ];
    }, $models);

    http_response_code(200);
    echo json_encode($response);

} catch (Exception $e) {
    error_log('API Error in models.php: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
