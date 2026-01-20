<?php
declare(strict_types=1);

/**
 * JSON-based Car Repository
 *
 * Provides functions to access car data from JSON files without database queries.
 * Uses static caching for performance and includes schema validation.
 */

/**
 * Configuration for JSON data paths
 */
const JSON_DATA_DIR = __DIR__ . '/../mocks/';
const JSON_CARSET_FILE = 'new_carset.json';
const JSON_DATA_FILE = 'data.json';

/**
 * Load and validate car dataset from JSON file with caching
 */
function load_car_dataset(): array {
    static $dataset = null;

    if ($dataset === null) {
        $jsonPath = JSON_DATA_DIR . JSON_CARSET_FILE;

        if (!file_exists($jsonPath)) {
            throw new RuntimeException("Car dataset JSON file not found: $jsonPath");
        }

        if (!is_readable($jsonPath)) {
            throw new RuntimeException("Car dataset JSON file is not readable: $jsonPath");
        }

        $jsonContent = file_get_contents($jsonPath);
        if ($jsonContent === false) {
            throw new RuntimeException("Failed to read car dataset JSON file: $jsonPath");
        }

        try {
            $dataset = json_decode($jsonContent, true, 512, JSON_THROW_ON_ERROR);
        } catch (\JsonException $e) {
            throw new RuntimeException(
                "Invalid JSON in car dataset file: " . $e->getMessage(),
                0,
                $e
            );
        }

        validate_car_dataset_schema($dataset);
    }

    return $dataset;
}

/**
 * Validate the car dataset JSON schema
 */
function validate_car_dataset_schema(array $dataset): void {
    if (!is_array($dataset)) {
        throw new RuntimeException("Car dataset JSON root must be an array");
    }

    if (empty($dataset)) {
        throw new RuntimeException("Car dataset JSON cannot be empty");
    }

    foreach ($dataset as $index => $car) {
        if (!is_array($car)) {
            throw new RuntimeException("Car entry at index $index must be an object");
        }

        $carMake = trim((string) ($car['make'] ?? ''));
        $carModel = trim((string) ($car['model'] ?? ''));
        $carSegment = trim((string) ($car['segment'] ?? ''));

        // Required fields validation
        $requiredFields = ['make', 'model', 'segment', 'variants'];
        foreach ($requiredFields as $field) {
            if (!array_key_exists($field, $car)) {
                throw new RuntimeException("Car entry at index $index missing required field: $field");
            }
        }

        // Validate make and model are non-empty strings
        if ($carMake === '') {
            throw new RuntimeException("Car entry at index $index: 'make' must be a non-empty string");
        }

        if ($carModel === '') {
            throw new RuntimeException("Car entry at index $index: 'model' must be a non-empty string");
        }

        if ($carSegment === '') {
            throw new RuntimeException("Car entry at index $index: 'segment' must be a non-empty string");
        }

        // Validate variants array
        if (!is_array($car['variants']) || empty($car['variants'])) {
            throw new RuntimeException("Car entry at index $index: 'variants' must be a non-empty array");
        }

        // Validate each variant
        foreach ($car['variants'] as $variantIndex => $variant) {
            if (!is_array($variant)) {
                throw new RuntimeException("Variant at index $variantIndex in car $index must be an object");
            }

            $requiredVariantFields = ['name', 'price', 'fuel_type'];
            foreach ($requiredVariantFields as $field) {
                if (!array_key_exists($field, $variant)) {
                    throw new RuntimeException("Variant at index $variantIndex in car $index missing required field: $field");
                }
            }

            $variantName = trim((string) ($variant['name'] ?? ''));
            $variantPrice = trim((string) ($variant['price'] ?? ''));
            $variantFuel = trim((string) ($variant['fuel_type'] ?? ''));

            if ($variantName === '') {
                throw new RuntimeException("Variant at index $variantIndex in car $index: 'name' must be a non-empty string");
            }

            if ($variantPrice === '') {
                throw new RuntimeException("Variant at index $variantIndex in car $index: 'price' must be a non-empty string");
            }

            if ($variantFuel === '') {
                throw new RuntimeException("Variant at index $variantIndex in car $index: 'fuel_type' must be a non-empty string");
            }
        }
    }
}

/**
 * Parse price string to float
 */
function json_parse_price(?string $price): float {
    $normalized = str_replace(['₹', 'Rs.', 'INR', ' ', ','], '', (string) ($price ?? ''));

    if ($normalized === '') {
        return 0.0;
    }

    if (strpos($normalized, 'L') !== false) {
        $normalized = str_replace('L', '', $normalized);
        return (float) $normalized * 100000;
    }

    if (strpos($normalized, 'Cr') !== false) {
        $normalized = str_replace('Cr', '', $normalized);
        return (float) $normalized * 10000000;
    }

    return (float) $normalized;
}

/**
 * Get all brands/manufacturers
 */
function json_get_brands(): array {
    $dataset = load_car_dataset();
    $brands = [];
    $seen = [];

    foreach ($dataset as $car) {
        $brandName = trim((string) ($car['make'] ?? ''));
        if ($brandName === '') {
            continue;
        }

        if (!in_array(strtolower($brandName), array_map('strtolower', $seen), true)) {
            $seen[] = $brandName;
            $brands[] = [
                'id' => count($brands) + 1,
                'name' => $brandName,
                'slug' => strtolower(str_replace(' ', '-', $brandName)),
                'country' => 'India',
                'logo' => null,
                'model_count' => 0,
                'min_price' => null,
                'max_price' => null,
            ];
        }
    }

    foreach ($brands as &$brand) {
        $brandModels = json_get_models_by_brand($brand['name']);
        $brand['model_count'] = count($brandModels);

        if (!empty($brandModels)) {
            $prices = [];
            foreach ($brandModels as $model) {
                $variantList = $model['variants'] ?? [];
                foreach ($variantList as $variant) {
                    $prices[] = $variant['price_numeric'] ?? json_parse_price($variant['price'] ?? '');
                }
            }
            $brand['min_price'] = !empty($prices) ? min($prices) : null;
            $brand['max_price'] = !empty($prices) ? max($prices) : null;
        }
    }

    usort($brands, static fn($a, $b) => strcmp($a['name'], $b['name']));

    return $brands;
}

/**
 * Get models by brand name (case-insensitive)
 */
function json_get_models_by_brand(string $brandName): array {
    $dataset = load_car_dataset();
    $models = [];
    $seen = [];

    $brandName = trim($brandName);

    foreach ($dataset as $car) {
        $carMake = trim((string) ($car['make'] ?? ''));
        $carModel = trim((string) ($car['model'] ?? ''));
        $carSegment = trim((string) ($car['segment'] ?? ''));

        if ($carMake === '' || $carModel === '') {
            continue;
        }

        if (strcasecmp($carMake, $brandName) === 0) {
            if (!in_array(strtolower($carModel), array_map('strtolower', $seen), true)) {
                $seen[] = $carModel;

                $variants = [];
                foreach ($dataset as $car2) {
                    $car2Make = trim((string) ($car2['make'] ?? ''));
                    $car2Model = trim((string) ($car2['model'] ?? ''));
                    if (strcasecmp($car2Make, $brandName) === 0 && strcasecmp($car2Model, $carModel) === 0) {
                        foreach (($car2['variants'] ?? []) as $variant) {
                            $variants[] = [
                                'id' => count($variants) + 1,
                                'name' => trim((string) ($variant['name'] ?? '')),
                                'fuel_type' => trim((string) ($variant['fuel_type'] ?? '')),
                                'transmission' => trim((string) ($variant['transmission'] ?? 'Manual')),
                                'price' => trim((string) ($variant['price'] ?? '')),
                                'price_numeric' => $variant['price_numeric'] ?? json_parse_price($variant['price'] ?? ''),
                                'engine_size' => trim((string) ($variant['engine_size'] ?? '')),
                                'horsepower' => trim((string) ($variant['horsepower'] ?? '')),
                            ];
                        }
                    }
                }

                usort($variants, static fn($a, $b) => $a['price_numeric'] <=> $b['price_numeric']);

                $models[] = [
                    'id' => count($models) + 1,
                    'name' => $carModel,
                    'slug' => strtolower(str_replace(' ', '-', $carModel)),
                    'brand' => $carMake,
                    'segment' => $carSegment,
                    'launch_year' => 2023,
                    'variants' => $variants,
                    'variant_count' => count($variants),
                    'fuel_types' => array_values(array_unique(array_column($variants, 'fuel_type'))),
                    'price_range' => [
                        'min' => !empty($variants) ? min(array_column($variants, 'price_numeric')) : 0,
                        'max' => !empty($variants) ? max(array_column($variants, 'price_numeric')) : 0,
                    ],
                    'image' => null,
                ];
            }
        }
    }

    usort($models, static fn($a, $b) => strcmp($a['name'], $b['name']));

    return $models;
}

/**
 * Get variants by model name (case-insensitive)
 */
function json_get_variants_by_model(string $modelName): array {
    $dataset = load_car_dataset();
    $variants = [];

    $modelName = trim($modelName);

    foreach ($dataset as $car) {
        $carModel = trim((string) ($car['model'] ?? ''));
        if ($carModel === '') {
            continue;
        }

        if (strcasecmp($carModel, $modelName) === 0) {
            foreach (($car['variants'] ?? []) as $variant) {
                $variants[] = [
                    'id' => count($variants) + 1,
                    'name' => trim((string) ($variant['name'] ?? '')),
                    'model' => $modelName,
                    'brand' => trim((string) ($car['make'] ?? '')),
                    'fuel_type' => trim((string) ($variant['fuel_type'] ?? '')),
                    'transmission' => trim((string) ($variant['transmission'] ?? 'Manual')),
                    'price' => trim((string) ($variant['price'] ?? '')),
                    'price_numeric' => $variant['price_numeric'] ?? json_parse_price($variant['price'] ?? ''),
                    'engine_size' => trim((string) ($variant['engine_size'] ?? '')),
                    'horsepower' => trim((string) ($variant['horsepower'] ?? '')),
                    'segment' => trim((string) ($car['segment'] ?? '')),
                ];
            }
        }
    }

    usort($variants, static fn($a, $b) => $a['price_numeric'] <=> $b['price_numeric']);

    return $variants;
}

/**
 * Search cars with filters
 */
function json_search(array $filters = []): array {
    $dataset = load_car_dataset();
    $results = [];

    $limit = isset($filters['limit']) ? max(1, (int) $filters['limit']) : 12;
    $offset = isset($filters['offset']) ? max(0, (int) $filters['offset']) : 0;

    $filterBrand = strtolower(trim((string) ($filters['brand'] ?? '')));
    $filterModel = strtolower(trim((string) ($filters['model'] ?? '')));
    $filterSearch = strtolower(trim((string) ($filters['search'] ?? '')));

    $filterFuelTypes = array_filter(array_map(
        static fn($val) => strtolower(trim((string) $val)),
        (array) ($filters['fuel_type'] ?? [])
    ));
    $filterTransmissions = array_filter(array_map(
        static fn($val) => strtolower(trim((string) $val)),
        (array) ($filters['transmission'] ?? [])
    ));

    $minPrice = isset($filters['min_price']) && $filters['min_price'] !== '' ? (float) $filters['min_price'] : null;
    $maxPrice = isset($filters['max_price']) && $filters['max_price'] !== '' ? (float) $filters['max_price'] : null;

    foreach ($dataset as $car) {
        $carMake = strtolower(trim((string) ($car['make'] ?? '')));
        $carModel = strtolower(trim((string) ($car['model'] ?? '')));
        $carSegment = strtolower(trim((string) ($car['segment'] ?? '')));

        foreach (($car['variants'] ?? []) as $variant) {
            $variantName = strtolower(trim((string) ($variant['name'] ?? '')));
            $variantFuel = strtolower(trim((string) ($variant['fuel_type'] ?? '')));
            $variantTransmission = strtolower(trim((string) ($variant['transmission'] ?? 'Manual')));
            $variantPrice = isset($variant['price_numeric'])
                ? (float) $variant['price_numeric']
                : json_parse_price($variant['price'] ?? '');

            $match = true;

            if ($filterBrand !== '' && $carMake !== $filterBrand) {
                $match = false;
            }

            if ($filterModel !== '' && $carModel !== $filterModel) {
                $match = false;
            }

            if (!empty($filterFuelTypes) && !in_array($variantFuel, $filterFuelTypes, true)) {
                $match = false;
            }

            if (!empty($filterTransmissions) && !in_array($variantTransmission, $filterTransmissions, true)) {
                $match = false;
            }

            if ($match && ($minPrice !== null || $maxPrice !== null)) {
                if ($minPrice !== null && $variantPrice < $minPrice) {
                    $match = false;
                }
                if ($maxPrice !== null && $variantPrice > $maxPrice) {
                    $match = false;
                }
            }

            if ($filterSearch !== '') {
                $searchable = $carMake . ' ' . $carModel . ' ' . $carSegment . ' ' . $variantName;
                if (strpos($searchable, $filterSearch) === false) {
                    $match = false;
                }
            }

            if ($match) {
                $results[] = [
                    'id' => count($results) + 1,
                    'brand' => trim((string) ($car['make'] ?? '')),
                    'model' => trim((string) ($car['model'] ?? '')),
                    'variant' => trim((string) ($variant['name'] ?? '')),
                    'segment' => trim((string) ($car['segment'] ?? '')),
                    'fuel_type' => trim((string) ($variant['fuel_type'] ?? '')),
                    'transmission' => trim((string) ($variant['transmission'] ?? 'Manual')),
                    'price' => trim((string) ($variant['price'] ?? '')),
                    'price_numeric' => $variantPrice,
                    'engine_size' => trim((string) ($variant['engine_size'] ?? '')),
                    'horsepower' => trim((string) ($variant['horsepower'] ?? '')),
                ];
            }
        }
    }

    $sortBy = $filters['sort_by'] ?? 'price_asc';
    switch ($sortBy) {
        case 'price_desc':
            usort($results, static fn($a, $b) => $b['price_numeric'] <=> $a['price_numeric']);
            break;
        case 'name_asc':
            usort($results, static fn($a, $b) => strcmp($a['model'], $b['model']));
            break;
        case 'name_desc':
            usort($results, static fn($a, $b) => strcmp($b['model'], $a['model']));
            break;
        default:
            usort($results, static fn($a, $b) => $a['price_numeric'] <=> $b['price_numeric']);
    }

    return array_slice($results, $offset, $limit);
}

/**
 * Get car by ID or slug
 */
function json_get_car(string|int $identifier): ?array {
    $dataset = load_car_dataset();

    if (is_numeric($identifier)) {
        $id = (int) $identifier;
        $counter = 1;
        foreach ($dataset as $car) {
            foreach (($car['variants'] ?? []) as $variant) {
                if ($counter === $id) {
                    return [
                        'id' => $id,
                        'brand' => trim((string) ($car['make'] ?? '')),
                        'model' => trim((string) ($car['model'] ?? '')),
                        'variant' => trim((string) ($variant['name'] ?? '')),
                        'segment' => trim((string) ($car['segment'] ?? '')),
                        'fuel_type' => trim((string) ($variant['fuel_type'] ?? '')),
                        'transmission' => trim((string) ($variant['transmission'] ?? 'Manual')),
                        'price' => trim((string) ($variant['price'] ?? '')),
                        'price_numeric' => $variant['price_numeric'] ?? json_parse_price($variant['price'] ?? ''),
                        'engine_size' => trim((string) ($variant['engine_size'] ?? '')),
                        'horsepower' => trim((string) ($variant['horsepower'] ?? '')),
                        'specs' => [],
                    ];
                }
                $counter++;
            }
        }
    }

    $slug = trim((string) $identifier);
    foreach ($dataset as $car) {
        foreach (($car['variants'] ?? []) as $variant) {
            $expectedSlug = strtolower(str_replace(
                ' ',
                '-',
                ($car['make'] ?? '') . '-' . ($car['model'] ?? '') . '-' . ($variant['name'] ?? '')
            ));
            if ($expectedSlug === strtolower($slug)) {
                return [
                    'id' => 1,
                    'brand' => trim((string) ($car['make'] ?? '')),
                    'model' => trim((string) ($car['model'] ?? '')),
                    'variant' => trim((string) ($variant['name'] ?? '')),
                    'segment' => trim((string) ($car['segment'] ?? '')),
                    'fuel_type' => trim((string) ($variant['fuel_type'] ?? '')),
                    'transmission' => trim((string) ($variant['transmission'] ?? 'Manual')),
                    'price' => trim((string) ($variant['price'] ?? '')),
                    'price_numeric' => $variant['price_numeric'] ?? json_parse_price($variant['price'] ?? ''),
                    'engine_size' => trim((string) ($variant['engine_size'] ?? '')),
                    'horsepower' => trim((string) ($variant['horsepower'] ?? '')),
                    'specs' => [],
                ];
            }
        }
    }

    return null;
}
