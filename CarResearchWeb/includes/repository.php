<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/json_car_repository.php';

/**
 * Repository functions for JSON-based car data
 * Simplified to work exclusively with JSON data source
 */

/**
 * Get all brands/manufacturers
 */
function getBrands(): array {
    return json_get_brands();
}

/**
 * Get models by brand name
 */
function getModelsByBrand(string $brandName): array {
    return json_get_models_by_brand($brandName);
}

/**
 * Get variants by model name
 */
function getVariantsByModel(string $modelName): array {
    return json_get_variants_by_model($modelName);
}

/**
 * Search cars with filters
 */
function searchCars(array $filters = []): array {
    return json_search($filters);
}

/**
 * Get car by ID or slug
 */
function getCar(string|int $identifier): ?array {
    return json_get_car($identifier);
}

/**
 * Legacy compatibility functions - these maintain the old interface
 * while internally using the new abstraction layer
 */

/**
 * Load car data from JSON file (legacy function)
 */
function load_car_data(): array
{
    return load_car_dataset();
}

/**
 * Parse price string to float
 */
function parse_price(string $price): float
{
    $price = str_replace('₹', '', $price);
    $price = str_replace(' ', '', $price);
    if (strpos($price, 'L') !== false) {
        $price = str_replace('L', '', $price);
        return (float) $price * 100000;
    } elseif (strpos($price, 'Cr') !== false) {
        $price = str_replace('Cr', '', $price);
        return (float) $price * 10000000;
    } else {
        return (float) $price;
    }
}

/**
 * Manufacturers
 */
function get_all_manufacturers(): array
{
    $data = load_car_data();
    $manufacturers = [];
    $seen = [];
    foreach ($data as $car) {
        $make = $car['make'];
        if (!in_array($make, $seen)) {
            $seen[] = $make;
            $manufacturers[] = [
                'id' => count($manufacturers) + 1, // Generate ID
                'name' => $make,
                'country' => 'India' // Default, as most are Indian brands
            ];
        }
    }
    usort($manufacturers, fn($a, $b) => strcmp($a['name'], $b['name']));
    return $manufacturers;
}

function get_manufacturer_by_id(int $id): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $manufacturer) {
        if ($manufacturer['id'] === $id) {
            return $manufacturer;
        }
    }
    return null;
}

function get_manufacturer_by_name(string $name): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $manufacturer) {
        if ($manufacturer['name'] === $name) {
            return $manufacturer;
        }
    }
    return null;
}

/**
 * Families
 */
function get_family_by_id(int $id): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $man) {
        $families = get_model_families_by_manufacturer($man['id']);
        foreach ($families as $family) {
            if ($family['id'] === $id) {
                return array_merge($family, [
                    'manufacturer_name' => $man['name'],
                    'manufacturer_id' => $man['id']
                ]);
            }
        }
    }
    return null;
}

function get_model_families_by_manufacturer(int $manufacturerId): array
{
    $data = load_car_data();
    $manufacturers = get_all_manufacturers();
    $manufacturer = null;
    foreach ($manufacturers as $man) {
        if ($man['id'] === $manufacturerId) {
            $manufacturer = $man;
            break;
        }
    }
    if (!$manufacturer) {
        return [];
    }

    $segments = [];
    $segmentCounts = [];
    foreach ($data as $car) {
        if ($car['make'] === $manufacturer['name']) {
            $segment = $car['segment'];
            if (!isset($segmentCounts[$segment])) {
                $segmentCounts[$segment] = 0;
                $segments[] = [
                    'id' => count($segments) + 1,
                    'manufacturer_id' => $manufacturerId,
                    'nameplate' => $segment,
                    'body_type' => $segment, // Use segment as body_type
                    'segment' => $segment,
                    'fuel_scope' => 'All' // Default
                ];
            }
            $segmentCounts[$segment]++;
        }
    }

    // Add model_count
    foreach ($segments as &$segment) {
        $segment['model_count'] = $segmentCounts[$segment['nameplate']];
    }

    usort($segments, fn($a, $b) => strcmp($a['nameplate'], $b['nameplate']));
    return $segments;
}

function get_featured_families(int $limit = 6): array
{
    $data = load_car_data();
    $families = [];
    $seen = [];
    foreach ($data as $car) {
        $key = $car['make'] . '-' . $car['segment'];
        if (!in_array($key, $seen)) {
            $seen[] = $key;
            $manufacturer = get_manufacturer_by_name($car['make']);
            if ($manufacturer) {
                $families[] = [
                    'id' => count($families) + 1,
                    'nameplate' => $car['segment'],
                    'body_type' => $car['segment'],
                    'segment' => $car['segment'],
                    'fuel_scope' => 'All',
                    'manufacturer_id' => $manufacturer['id'],
                    'manufacturer_name' => $manufacturer['name']
                ];
            }
            if (count($families) >= $limit) {
                break;
            }
        }
    }
    return $families;
}

/**
 * Models
 */
function get_models_by_family(int $familyId): array
{
    $data = load_car_data();
    $manufacturers = get_all_manufacturers();
    $segments = [];
    foreach ($manufacturers as $man) {
        $manSegments = get_model_families_by_manufacturer($man['id']);
        $segments = array_merge($segments, $manSegments);
    }

    $segment = null;
    foreach ($segments as $seg) {
        if ($seg['id'] === $familyId) {
            $segment = $seg;
            break;
        }
    }
    if (!$segment) {
        return [];
    }

    $models = [];
    $seen = [];
    foreach ($data as $car) {
        if ($car['segment'] === $segment['nameplate']) {
            $modelKey = $car['model'];
            if (!in_array($modelKey, $seen)) {
                $seen[] = $modelKey;
                $manufacturer = get_manufacturer_by_name($car['make']);
                $models[] = [
                    'id' => count($models) + 1,
                    'name' => $car['model'],
                    'launch_year' => $car['year'] ?? 2023, // Default if not present
                    'manufacturer_id' => $manufacturer['id'],
                    'manufacturer_name' => $manufacturer['name'],
                    'family_nameplate' => $segment['nameplate'],
                    'body_type' => $segment['body_type'],
                    'segment' => $segment['segment'],
                    'fuel_scope' => $segment['fuel_scope']
                ];
            }
        }
    }

    usort($models, fn($a, $b) => $b['launch_year'] <=> $a['launch_year'] ?: strcmp($a['name'], $b['name']));
    return $models;
}

function get_model_by_id(int $id): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $man) {
        $families = get_model_families_by_manufacturer($man['id']);
        foreach ($families as $family) {
            $models = get_models_by_family($family['id']);
            foreach ($models as $model) {
                if ($model['id'] === $id) {
                    return $model;
                }
            }
        }
    }
    return null;
}

/**
 * Variants
 */
function get_variants_by_model(int $modelId): array
{
    $model = get_model_by_id($modelId);
    if (!$model) {
        return [];
    }

    $data = load_car_data();
    $variants = [];
    foreach ($data as $car) {
        if ($car['model'] === $model['name']) {
            foreach ($car['variants'] as $var) {
                $variants[] = [
                    'id' => count($variants) + 1,
                    'variant_name' => $var['name'],
                    'fuel_type' => $var['fuel_type'],
                    'transmission' => $var['transmission'],
                    'ex_showroom_price' => parse_price($var['price']),
                    'model_name' => $car['model'],
                    'manufacturer_name' => $car['make']
                ];
            }
        }
    }

    usort($variants, fn($a, $b) => $a['ex_showroom_price'] <=> $b['ex_showroom_price'] ?: strcmp($a['variant_name'], $b['variant_name']));
    return $variants;
}

function get_variant_by_id(int $id): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $man) {
        $families = get_model_families_by_manufacturer($man['id']);
        foreach ($families as $family) {
            $models = get_models_by_family($family['id']);
            foreach ($models as $model) {
                $variants = get_variants_by_model($model['id']);
                foreach ($variants as $variant) {
                    if ($variant['id'] === $id) {
                        return array_merge($variant, [
                            'model_name' => $model['name'],
                            'family_id' => $family['id'],
                            'family_nameplate' => $family['nameplate'],
                            'body_type' => $family['body_type'],
                            'manufacturer_id' => $man['id'],
                            'manufacturer_name' => $man['name']
                        ]);
                    }
                }
            }
        }
    }
    return null;
}

function get_featured_variants(int $limit = 6): array
{
    $data = load_car_data();
    $variants = [];
    $seen = [];
    foreach ($data as $car) {
        foreach ($car['variants'] as $var) {
            $key = $car['model'] . '-' . $var['name'];
            if (!in_array($key, $seen)) {
                $seen[] = $key;
                $variants[] = [
                    'id' => count($variants) + 1,
                    'variant_name' => $var['name'],
                    'fuel_type' => $var['fuel_type'],
                    'transmission' => $var['transmission'],
                    'ex_showroom_price' => parse_price($var['price']),
                    'model_name' => $car['model'],
                    'manufacturer_name' => $car['make']
                ];
                if (count($variants) >= $limit) {
                    break 2;
                }
            }
        }
    }
    return $variants;
}

/**
 * Helper functions for search
 */
function matches_filters(array $car, array $variant, array $filters): bool
{
    if (!empty($filters['manufacturer_id'])) {
        $manufacturer = get_manufacturer_by_name($car['make']);
        if (!$manufacturer || $manufacturer['id'] !== (int) $filters['manufacturer_id']) {
            return false;
        }
    }

    if (!empty($filters['family_id'])) {
        $family = get_family_by_segment($car['segment']);
        if (!$family || $family['id'] !== (int) $filters['family_id']) {
            return false;
        }
    }

    if (!empty($filters['body_type'])) {
        $body_types = (array) $filters['body_type'];
        if (!in_array($car['segment'], $body_types)) {
            return false;
        }
    }

    if (!empty($filters['fuel_type'])) {
        $fuel_types = (array) $filters['fuel_type'];
        if (!in_array($variant['fuel_type'], $fuel_types)) {
            return false;
        }
    }

    if (!empty($filters['transmission'])) {
        $transmissions = (array) $filters['transmission'];
        if (!in_array($variant['transmission'], $transmissions)) {
            return false;
        }
    }

    if (isset($filters['min_budget']) && $filters['min_budget'] !== null) {
        $parsed_price = parse_price($variant['price']);
        if ($parsed_price < (float) $filters['min_budget']) {
            return false;
        }
    }

    if (isset($filters['max_budget']) && $filters['max_budget'] !== null) {
        $parsed_price = parse_price($variant['price']);
        if ($parsed_price > (float) $filters['max_budget']) {
            return false;
        }
    }

    if (!empty($filters['search_text'])) {
        $search_text = strtolower($filters['search_text']);
        if (stripos($car['make'], $search_text) === false &&
            stripos($car['segment'], $search_text) === false &&
            stripos($car['model'], $search_text) === false &&
            stripos($variant['name'], $search_text) === false) {
            return false;
        }
    }

    return true;
}

function get_family_by_segment(string $segment): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $man) {
        $families = get_model_families_by_manufacturer($man['id']);
        foreach ($families as $family) {
            if ($family['nameplate'] === $segment) {
                return $family;
            }
        }
    }
    return null;
}

function get_model_by_name(string $modelName): ?array
{
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $man) {
        $families = get_model_families_by_manufacturer($man['id']);
        foreach ($families as $family) {
            $models = get_models_by_family($family['id']);
            foreach ($models as $model) {
                if ($model['name'] === $modelName) {
                    return $model;
                }
            }
        }
    }
    return null;
}

/**
 * Specs & features
 */
function get_specs_for_variant(int $variantId): ?array
{
    // Specs not available in JSON data, return null
    return null;
}

function get_features_for_variant(int $variantId): array
{
    // Features not available in JSON data, return empty array
    return [];
}

function get_grouped_features_for_variant(int $variantId): array
{
    $features = get_features_for_variant($variantId);
    $grouped = [];

    foreach ($features as $feature) {
        $category = trim((string) ($feature['category'] ?? 'Other'));
        if ($category === '') {
            $category = 'Other';
        }
        if (!isset($grouped[$category])) {
            $grouped[$category] = [];
        }
        $grouped[$category][] = $feature;
    }

    return $grouped;
}

/**
 * Pricing
 */
function get_prices_for_variant(int $variantId, ?int $cityId = null): array
{
    // Pricing history not available in JSON data, return empty array
    return [];
}

function get_current_price_for_variant(int $variantId, ?int $cityId = null): ?array
{
    // Current price not available in JSON data, return null
    return null;
}

/**
 * Search
 *
 * @param array<string, mixed> $filters
 * @return array<int, array<string, mixed>>
 */
function search_cars(array $filters): array
{
    $data = load_car_data();
    $results = [];
    $id_counter = 1;
    foreach ($data as $car) {
        foreach ($car['variants'] as $var) {
            if (matches_filters($car, $var, $filters)) {
                $manufacturer = get_manufacturer_by_name($car['make']);
                $family = get_family_by_segment($car['segment']);
                $model = get_model_by_name($car['model']);
                $results[] = [
                    'manufacturer_id' => $manufacturer['id'],
                    'manufacturer_name' => $manufacturer['name'],
                    'family_id' => $family['id'],
                    'family_nameplate' => $family['nameplate'],
                    'body_type' => $family['body_type'],
                    'model_id' => $model['id'],
                    'model_name' => $model['name'],
                    'variant_id' => $id_counter++,
                    'variant_name' => $var['name'],
                    'fuel_type' => $var['fuel_type'],
                    'transmission' => $var['transmission'],
                    'ex_showroom_price' => parse_price($var['price']),
                    'launch_year' => $model['launch_year']
                ];
            }
        }
    }

    // Sorting
    $sort = $filters['sort_by'] ?? 'price_asc';
    if ($sort === 'price_desc') {
        usort($results, fn($a, $b) => $b['ex_showroom_price'] <=> $a['ex_showroom_price']);
    } elseif ($sort === 'year_desc') {
        usort($results, fn($a, $b) => $b['launch_year'] <=> $a['launch_year']);
    } elseif ($sort === 'year_asc') {
        usort($results, fn($a, $b) => $a['launch_year'] <=> $b['launch_year']);
    } else {
        usort($results, fn($a, $b) => $a['ex_showroom_price'] <=> $b['ex_showroom_price']);
    }

    // Limit and offset
    $limit = isset($filters['limit']) ? max(1, (int) $filters['limit']) : 20;
    $offset = isset($filters['offset']) ? max(0, (int) $filters['offset']) : 0;
    return array_slice($results, $offset, $limit);
}

/**
 * @param array<string, mixed> $filters
 */
function search_cars_count(array $filters): int
{
    $data = load_car_data();
    $count = 0;
    foreach ($data as $car) {
        foreach ($car['variants'] as $var) {
            if (matches_filters($car, $var, $filters)) {
                $count++;
            }
        }
    }
    return $count;
}


