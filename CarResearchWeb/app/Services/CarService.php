<?php
declare(strict_types=1);

namespace App\Services;

use App\Repositories\JsonCarRepository;

final class CarService
{
    private JsonCarRepository $repo;

    public function __construct(JsonCarRepository $repo)
    {
        $this->repo = $repo;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getBrands(): array
    {
        return $this->repo->getBrands();
    }

    /**
     * @return array<string, mixed>|null
     */
    public function findBrandByIdOrName(int $id = 0, string $name = ''): ?array
    {
        $brands = $this->getBrands();
        $needleName = strtolower(trim($name));
        foreach ($brands as $brand) {
            if ($id > 0 && $brand['id'] === $id) {
                return $brand;
            }
            if ($needleName !== '' && strtolower(trim($brand['name'] ?? '')) === $needleName) {
                return $brand;
            }
        }

        return null;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByBrand(string $brandName): array
    {
        return $this->repo->getModelsByMake($brandName);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getModel(string $modelName): ?array
    {
        return $this->repo->getModelByName($modelName);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModel(string $modelName): array
    {
        return $this->repo->getVariantsByModel($modelName);
    }

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function searchVariants(array $filters): array
    {
        return $this->repo->search($filters);
    }

    /**
     * @param array<string, mixed> $filters
     */
    public function searchVariantsCount(array $filters): int
    {
        // Avoid loading all results twice by mirroring the repo's pagination.
        $filtersNoLimit = $filters;
        $filtersNoLimit['limit'] = PHP_INT_MAX;
        $filtersNoLimit['offset'] = 0;
        return count($this->repo->search($filtersNoLimit));
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getFeaturedFamilies(int $limit = 6): array
    {
        $families = [];
        foreach ($this->getBrands() as $brand) {
            $models = $this->getModelsByBrand($brand['name']);
            foreach ($models as $model) {
                $key = strtolower($brand['name'] . '-' . ($model['segment'] ?? ''));
                if (isset($families[$key])) {
                    continue;
                }
                $families[$key] = [
                    'id' => count($families) + 1,
                    'manufacturer_id' => $brand['id'],
                    'manufacturer_name' => $brand['name'],
                    'nameplate' => $model['segment'] ?? 'Car',
                    'body_type' => $model['segment'] ?? 'Car',
                    'segment' => $model['segment'] ?? 'Car',
                    'fuel_scope' => 'All',
                ];
                if (count($families) >= $limit) {
                    break 2;
                }
            }
        }

        return array_values($families);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getFeaturedVariants(int $limit = 6): array
    {
        $results = $this->repo->search([
            'limit' => $limit,
            'offset' => 0,
            'sort_by' => 'price_asc',
        ]);

        return array_map(static function ($row) {
            return [
                'id' => $row['id'],
                'manufacturer_name' => $row['brand'],
                'model_name' => $row['model'],
                'variant_name' => $row['variant'],
                'fuel_type' => $row['fuel_type'],
                'transmission' => $row['transmission'],
                'ex_showroom_price' => $row['price_numeric'],
            ];
        }, $results);
    }
}
