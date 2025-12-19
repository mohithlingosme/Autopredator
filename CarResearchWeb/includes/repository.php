<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/Support/Autoload.php';
require_once __DIR__ . '/config.php';

use App\Repositories\JsonCarRepository;
use App\Services\CarService;

/**
 * Resolve the shared CarService instance.
 */
function car_service(): CarService
{
    static $service = null;

    if ($service === null) {
        $dataDir = __DIR__ . '/../data';
        $repo = new JsonCarRepository($dataDir);
        $service = new CarService($repo);
    }

    return $service;
}

/**
 * Compatibility wrappers for legacy function names.
 */
function get_all_manufacturers(): array
{
    return car_service()->getBrands();
}

function get_manufacturer_by_id(int $id): ?array
{
    return car_service()->findBrandByIdOrName($id);
}

function get_manufacturer_by_name(string $name): ?array
{
    return car_service()->findBrandByIdOrName(0, $name);
}

function get_model_families_by_manufacturer(int $manufacturerId): array
{
    $brand = get_manufacturer_by_id($manufacturerId);
    if ($brand === null) {
        return [];
    }

    $families = [];
    $segments = [];
    foreach (car_service()->getModelsByBrand($brand['name']) as $model) {
        $segment = $model['segment'] ?? 'Car';
        if (!isset($segments[$segment])) {
            $segments[$segment] = 0;
            $families[] = [
                'id' => count($families) + 1,
                'manufacturer_id' => $brand['id'],
                'nameplate' => $segment,
                'body_type' => $segment,
                'segment' => $segment,
                'fuel_scope' => 'All',
            ];
        }
        $segments[$segment]++;
    }

    foreach ($families as &$family) {
        $family['model_count'] = $segments[$family['nameplate']] ?? 0;
    }

    return $families;
}

function get_models_by_family(int $familyId): array
{
    // Families are generated per manufacturer; fall back to all models.
    $models = [];
    foreach (get_all_manufacturers() as $brand) {
        $brandModels = car_service()->getModelsByBrand($brand['name']);
        foreach ($brandModels as $model) {
            $models[] = array_merge($model, [
                'manufacturer_id' => $brand['id'],
                'manufacturer_name' => $brand['name'],
                'family_id' => $familyId,
                'family_nameplate' => $model['segment'] ?? 'Car',
                'body_type' => $model['segment'] ?? 'Car',
            ]);
        }
    }

    return $models;
}

function get_model_by_id(int $id): ?array
{
    foreach (get_all_manufacturers() as $brand) {
        foreach (car_service()->getModelsByBrand($brand['name']) as $index => $model) {
            $virtualId = $index + 1;
            if ($virtualId === $id) {
                return array_merge($model, [
                    'id' => $virtualId,
                    'manufacturer_id' => $brand['id'],
                    'manufacturer_name' => $brand['name'],
                ]);
            }
        }
    }
    return null;
}

function get_model_by_name(string $modelName): ?array
{
    $model = car_service()->getModel($modelName);
    if ($model === null) {
        return null;
    }

    $brand = get_manufacturer_by_name($model['make']);
    return array_merge($model, [
        'manufacturer_id' => $brand['id'] ?? 0,
        'manufacturer_name' => $brand['name'] ?? $model['make'],
    ]);
}

function get_variants_by_model(int $modelId): array
{
    $model = get_model_by_id($modelId);
    if ($model === null) {
        return [];
    }

    $variants = car_service()->getVariantsByModel($model['model'] ?? $model['name']);
    $list = [];
    foreach ($variants as $index => $variant) {
        $list[] = [
            'id' => $index + 1,
            'variant_name' => $variant['name'],
            'fuel_type' => $variant['fuel_type'],
            'transmission' => $variant['transmission'],
            'ex_showroom_price' => $variant['price_numeric'],
            'model_name' => $model['model'] ?? $model['name'],
            'manufacturer_name' => $model['manufacturer_name'] ?? '',
        ];
    }

    return $list;
}

function get_variant_by_id(int $id): ?array
{
    $all = car_service()->searchVariants([
        'limit' => PHP_INT_MAX,
        'offset' => 0,
    ]);

    foreach ($all as $variant) {
        if ((int) ($variant['id'] ?? 0) === $id) {
            $brand = get_manufacturer_by_name($variant['brand'] ?? '') ?? ['id' => 0, 'name' => $variant['brand'] ?? ''];
            return [
                'id' => $id,
                'variant_name' => $variant['variant'] ?? ($variant['name'] ?? ''),
                'fuel_type' => $variant['fuel_type'] ?? '',
                'transmission' => $variant['transmission'] ?? '',
                'ex_showroom_price' => $variant['price_numeric'] ?? 0,
                'model_name' => $variant['model'] ?? '',
                'manufacturer_name' => $brand['name'],
                'model_id' => $variant['id'] ?? $id,
                'manufacturer_id' => $brand['id'],
                'body_type' => $variant['segment'] ?? 'Car',
            ];
        }
    }

    return null;
}

function get_featured_families(int $limit = 6): array
{
    return car_service()->getFeaturedFamilies($limit);
}

function get_featured_variants(int $limit = 6): array
{
    return car_service()->getFeaturedVariants($limit);
}

/**
 * @param array<string, mixed> $filters
 * @return array<int, array<string, mixed>>
 */
function search_cars(array $filters): array
{
    $filtersForRepo = $filters;
    if (!empty($filters['manufacturer_id'])) {
        $brand = get_manufacturer_by_id((int) $filters['manufacturer_id']);
        if ($brand !== null) {
            $filtersForRepo['brand'] = $brand['name'];
        }
    }

    $results = car_service()->searchVariants($filtersForRepo);
    return array_map(static function ($row) {
        return [
            'manufacturer_name' => $row['brand'],
            'family_nameplate' => $row['model'],
            'model_name' => $row['model'],
            'variant_name' => $row['variant'],
            'body_type' => $row['segment'],
            'fuel_type' => $row['fuel_type'],
            'transmission' => $row['transmission'],
            'ex_showroom_price' => $row['price_numeric'],
            'variant_id' => $row['id'],
        ];
    }, $results);
}

function search_cars_count(array $filters): int
{
    $filtersForRepo = $filters;
    if (!empty($filters['manufacturer_id'])) {
        $brand = get_manufacturer_by_id((int) $filters['manufacturer_id']);
        if ($brand !== null) {
            $filtersForRepo['brand'] = $brand['name'];
        }
    }
    return car_service()->searchVariantsCount($filtersForRepo);
}
