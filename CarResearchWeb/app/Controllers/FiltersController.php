<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\CarRepositoryInterface;
use App\Support\CacheHelper;

final class FiltersController
{
    private CarRepositoryInterface $repo;
    private CacheHelper $cache;

    public function __construct(CarRepositoryInterface $repo)
    {
        $this->repo = $repo;
        $this->cache = new CacheHelper();
    }

    public function handle(string $method): void
    {
        if ($method !== 'GET') {
            http_response_code(405);
            echo json_encode(['ok' => false, 'error' => ['code' => 'METHOD_NOT_ALLOWED', 'message' => 'Only GET allowed']]);
            return;
        }

        $data = $this->getFilters();

        $etag = md5(json_encode($data));
        if ($this->cache->checkETag($etag)) {
            http_response_code(304);
            return;
        }

        header('ETag: "' . $etag . '"');
        header('Cache-Control: public, max-age=3600'); // 1 hour
        echo json_encode(['ok' => true, 'data' => $data]);
    }

    private function getFilters(): array
    {
        $brands = array_map(fn($brand) => [
            'name' => $brand['name'],
            'slug' => strtolower(str_replace(' ', '-', $brand['name'])),
        ], $this->repo->getBrands());

        // Simplified - in real implementation, would aggregate unique values
        return [
            'brands' => $brands,
            'body_types' => ['SUV', 'Sedan', 'Hatchback', 'Coupe', 'Convertible'],
            'fuel_types' => ['Petrol', 'Diesel', 'Electric', 'Hybrid'],
            'transmissions' => ['Manual', 'Automatic', 'CVT'],
            'seating_capacities' => [4, 5, 6, 7, 8],
            'price_ranges' => [
                ['min' => 0, 'max' => 500000, 'label' => 'Under 5L'],
                ['min' => 500000, 'max' => 1000000, 'label' => '5L - 10L'],
                ['min' => 1000000, 'max' => 2000000, 'label' => '10L - 20L'],
                ['min' => 2000000, 'max' => 5000000, 'label' => '20L - 50L'],
                ['min' => 5000000, 'max' => null, 'label' => 'Above 50L'],
            ],
        ];
    }
}
