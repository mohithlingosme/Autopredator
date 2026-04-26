<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\CarRepositoryInterface;
use App\Support\CacheHelper;

final class BrandsController
{
    private CarRepositoryInterface $repo;
    private CacheHelper $cache;

    public function __construct(CarRepositoryInterface $repo)
    {
        $this->repo = $repo;
        $this->cache = new CacheHelper();
    }

    public function handle(string $method, string $param): void
    {
        if ($method !== 'GET') {
            http_response_code(405);
            echo json_encode(['ok' => false, 'error' => ['code' => 'METHOD_NOT_ALLOWED', 'message' => 'Only GET allowed']]);
            return;
        }

        if ($param === '') {
            $this->getBrands();
        } else {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Brand endpoint not found']]);
        }
    }

    private function getBrands(): void
    {
        $brands = $this->repo->getBrands();
        $data = array_map(fn($brand) => [
            'name' => $brand['name'],
            'slug' => strtolower(str_replace(' ', '-', $brand['name'])),
            'logo_url' => $brand['logo'] ?? null,
            'model_count' => count($this->repo->getModelsByMake($brand['name'])),
        ], $brands);

        $etag = md5(json_encode($data));
        if ($this->cache->checkETag($etag)) {
            http_response_code(304);
            return;
        }

        header('ETag: "' . $etag . '"');
        header('Cache-Control: public, max-age=3600'); // 1 hour
        echo json_encode(['ok' => true, 'data' => $data]);
    }
}
