<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\CarRepositoryInterface;
use App\Support\CacheHelper;

final class VariantsController
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
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Variant slug required']]);
            return;
        }

        $this->getVariant($param);
    }

    private function getVariant(string $variantSlug): void
    {
        $variantName = ucwords(str_replace('-', ' ', $variantSlug));
        $variants = $this->repo->search(['variant' => $variantName]);
        $variant = $variants[0] ?? null;

        if (!$variant) {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => ['code' => 'NOT_FOUND', 'message' => 'Variant not found']]);
            return;
        }

        $data = [
            'id' => $variant['id'],
            'name' => $variant['variant'],
            'slug' => $variantSlug,
            'model' => $variant['model'],
            'brand' => $variant['brand'],
            'specs' => [
                'engine' => $variant['engine'] ?? '',
                'power' => $variant['power'] ?? '',
                'torque' => $variant['torque'] ?? '',
                'fuel_type' => $variant['fuel_type'],
                'transmission' => $variant['transmission'],
                'seating_capacity' => $variant['seating_capacity'] ?? null,
                'mileage' => $variant['mileage'] ?? '',
            ],
            'features' => [], // Placeholder, would need feature mapping
            'prices' => [
                'ex_showroom' => $variant['price_numeric'] ?? null,
                'on_road' => null, // Calculate if needed
            ],
            'images' => [], // Placeholder
            'updated_at' => $variant['updated_at'] ?? date('c'),
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
