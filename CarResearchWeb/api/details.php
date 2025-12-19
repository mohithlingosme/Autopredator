<?php
declare(strict_types=1);

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../app/Support/Autoload.php';

use App\Data\DetailRepository;
use App\Data\JsonLoader;
use App\Support\Logger;

header('Content-Type: application/json; charset=utf-8');

$slug = strtolower(trim($_GET['slug'] ?? ''));
$loader = new JsonLoader(DATA_DIR);
$repo = new DetailRepository($loader);

if ($slug === '') {
    http_response_code(400);
    echo json_encode(['error' => 'Missing slug'], JSON_UNESCAPED_UNICODE);
    exit;
}

$details = $repo->getDetailsBySlug($slug);

if ($details === null) {
    Logger::error('Details lookup failed', ['slug' => $slug]);
    http_response_code(404);
    echo json_encode(['error' => 'Not found'], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode($details, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
