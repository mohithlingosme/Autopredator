<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\CarRepositoryInterface;
use App\Services\CarService;
use App\Support\CacheHelper;

final class SearchController
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

        $query = $_GET['q'] ?? '';
        $filters = $this->parseFilters();
        $page = (int) ($_GET['page'] ?? 1);
        $limit = (int) ($_GET['limit'] ?? 20);

        $filters['limit'] = $limit;
        $filters['offset'] = ($page - 1) * $limit;

        $results = $this->service->searchVariants($filters);
        $total = $this->service->searchVariantsCount($filters);

        $data = [
            'items' => $results,
            'total' => $total,
            'page' => $page,
            'limit' => $limit,
            'facets' => $this->getFacets(),
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

    private function parseFilters(): array
    {
        $filters = [];

        if (!empty($_GET['brand_slug'])) {
            $filters['brand'] = ucwords(str_replace('-', ' ', $_GET['brand_slug']));
        }

        if (!empty($_GET['body_type'])) {
            $filters['segment'] = $_GET['body_type'];
        }

        if (!empty($_GET['fuel_types'])) {
            $filters['fuel_type'] = explode(',', $_GET['fuel_types']);
        }

        if (!empty($_GET['transmission'])) {
            $filters['transmission'] = $_GET['transmission'];
        }

        if (!empty($_GET['seating'])) {
            $filters['seating_capacity'] = (int) $_GET['seating'];
        }

        if (!empty($_GET['price_min'])) {
            $filters['price_min'] = (int) $_GET['price_min'];
        }

        if (!empty($_GET['price_max'])) {
            $filters['price_max'] = (int) $_GET['price_max'];
        }

        if (!empty($_GET['sort'])) {
            $filters['sort_by'] = $_GET['sort'];
        }

        return $filters;
    }

    private function getFacets(): array
    {
        // Simplified facets - in real implementation, would aggregate from data
        return [
            'brands' => [], // Would populate from repo
            'body_types' => ['SUV', 'Sedan', 'Hatchback'],
            'fuel_types' => ['Petrol', 'Diesel', 'Electric'],
            'transmissions' => ['Manual', 'Automatic'],
            'seating' => [4, 5, 7],
            'price_ranges' => [
                ['min' => 0, 'max' => 500000],
                ['min' => 500000, 'max' => 1000000],
                ['min' => 1000000, 'max' => 2000000],
            ],
        ];
    }
}
