<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\CarRepositoryInterface;
use App\Services\CarService;
use App\Support\CacheHelper;

final class CompareController
{
    private CarService $service;
    private CacheHelper $cache;

    public function __construct(CarRepositoryInterface $repo)
    {
        $this->service = new CarService($repo);
        $this->cache = new CacheHelper();
    }

    public function handle(string $method): void
    {
        if ($method !== 'GET') {
            http_response_code(405);
            echo json_encode(['ok' => false, 'error' => ['code' => 'METHOD_NOT_ALLOWED', 'message' => 'Only GET allowed']]);
            return;
        }

        $variantSlugs = $_GET['v'] ?? '';
        if (!$variantSlugs) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'Missing variant slugs parameter "v"']]);
            return;
        }

        $slugs = explode(',', $variantSlugs);
        if (count($slugs) < 2) {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'At least 2 variants required for comparison']]);
            return;
        }

        $data = $this->service->getCompareData($slugs);

        $etag = md5(json_encode($data));
        if ($this->cache->checkETag($etag)) {
            http_response_code(304);
            return;
        }

        header('ETag: "' . $etag . '"');
        header('Cache-Control: public, max-age=1800'); // 30 min
        echo json_encode(['ok' => true, 'data' => $data]);
    }
}
