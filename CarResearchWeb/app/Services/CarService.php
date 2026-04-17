<?php
declare(strict_types=1);

namespace App\Services;

use App\Repositories\CarRepositoryInterface;

final class CarService
{
    private CarRepositoryInterface $repo;

    public function __construct(CarRepositoryInterface $repo)
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
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByBrandSlug(string $brandSlug): array
    {
        if (method_exists($this->repo, 'getModelsByBrandSlug')) {
            return $this->repo->getModelsByBrandSlug($brandSlug);
        }
        return $this->repo->getModelsByMake($brandSlug);
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
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModelSlug(string $modelSlug): array
    {
        if (method_exists($this->repo, 'getVariantsByModelSlug')) {
            return $this->repo->getVariantsByModelSlug($modelSlug);
        }
        return $this->repo->getVariantsByModel($modelSlug);
    }

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function searchVariants(array $filters): array
    {
        if (method_exists($this->repo, 'searchVariants')) {
            return $this->repo->searchVariants($filters);
        }
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

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantById(int $id): ?array
    {
        return $this->repo->getVariantById($id);
    }

    /**
     * @param array<int, string> $variantSlugs
     * @return array<string, mixed>
     */
    public function getCompareData(array $variantSlugs): array
    {
        $variants = [];
        $specRows = [];
        $featureRows = [];

        foreach ($variantSlugs as $slug) {
            $variantName = ucwords(str_replace('-', ' ', $slug));
            $results = $this->repo->search(['variant' => $variantName]);
            if ($results) {
                $variant = $results[0];
                $variants[$slug] = [
                    'id' => $variant['id'],
                    'name' => $variant['variant'],
                    'model' => $variant['model'],
                    'brand' => $variant['brand'],
                    'price' => $variant['price_numeric'],
                ];
            }
        }

        // Build spec rows (simplified)
        $specKeys = ['engine', 'power', 'torque', 'fuel_type', 'transmission', 'seating_capacity', 'mileage'];
        foreach ($specKeys as $key) {
            $values = [];
            foreach ($variantSlugs as $slug) {
                if (isset($variants[$slug])) {
                    $variant = $this->repo->search(['variant' => ucwords(str_replace('-', ' ', $slug))])[0];
                    $values[$slug] = $variant[$key] ?? 'unknown';
                }
            }
            $specRows[] = [
                'key' => $key,
                'label' => ucwords(str_replace('_', ' ', $key)),
                'unit' => in_array($key, ['power', 'torque']) ? 'hp/Nm' : '',
                'values' => $values,
            ];
        }

        // Feature rows (placeholder)
        $featureRows = [
            [
                'key' => 'airbags',
                'label' => 'Airbags',
                'values' => array_fill_keys($variantSlugs, 'unknown'),
            ],
        ];

        return [
            'variants' => array_values($variants),
            'spec_rows' => $specRows,
            'feature_rows' => $featureRows,
        ];
    }
}
