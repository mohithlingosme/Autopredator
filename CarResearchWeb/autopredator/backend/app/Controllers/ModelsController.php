<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\CarRepositoryInterface;
use App\Services\CarService;
use App\Support\CacheHelper;

final class ModelsController
{
    private CarService $service;
    private CacheHelper $cache;

    public function __construct(CarRepositoryInterface $repo)
    {
        $this->service = new CarService($repo);
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
            $brandSlug = $_GET['brand'] ?? '';
            if (!$brandSlug) {
                http_response_code(400);
                echo json_encode(['ok' => false, 'error' => ['code' => 'BAD_REQUEST', 'message' => 'brand parameter required']]);
                return;
            }
            $this->getModelsByBrand($brandSlug);
        } else {
            $this->getModel($param);
        }
    }

    private function getModelsByBrand(string $brandSlug): void
    {
        $brandName = ucwords(str_replace('-', ' ', $brandSlug));
        $models = $this->service->getModelsByBrand($brandName);

        $data = array_map(fn($model) => [
            'name' => $model['name'],
            'slug' => strtolower(str_replace(' ', '-', $model['name'])),
            'body_type' => $model['segment'] ?? 'Car',
            'price_min' => $model['price_min'] ?? null,
            'price_max' => $model['price_max'] ?? null,
            'fuel_options' => [], // Would need to aggregate
            'transmission_options' => [], // Would need to aggregate
        ], $models);

        $etag = md5(json_encode($data));
        if ($this->cache->checkETag($etag)) {
            http_response_code(304);
            return;
        }

        header('ETag: "' . $etag . '"');
        header('Cache-Control: public, max-age=3600'); // 1 hour
        echo json_encode(['ok' => true, 'data' => $data]);
    }

    private function getModel(string $modelSlug): void
    {
        $modelName = ucwords(str_replace('-', ' ', $modelSlug));
        $model = $this->service->getModel($modelName);

        if (!$model) {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Model not found']]);
            return;
        }

        $variants = $this->service->getVariantsByModel($modelName);
        $data = [
            'id' => $model['id'] ?? null,
            'name' => $model['name'],
            'slug' => $modelSlug,
            'brand' => $model['brand'] ?? '',
            'body_type' => $model['segment'] ?? 'Car',
            'key_variants' => array_slice(array_map(fn($v) => [
                'name' => $v['variant'],
                'slug' => strtolower(str_replace(' ', '-', $v['variant'])),
                'price' => $v['price_numeric'],
            ], $variants), 0, 3),
            'faqs' => [], // Placeholder
            'competitors' => [], // Placeholder
        ];

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
