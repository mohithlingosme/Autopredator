<?php
declare(strict_types=1);

/**
 * JSON-based Car Repository
 *
 * Provides functions to access car data from JSON files without database queries.
 * Uses static caching for performance.
 */

/**
 * Load car dataset from JSON file with caching
 */
function load_car_dataset(): array {
    static $dataset = null;

    if ($dataset === null) {
        $jsonPath = __DIR__ . '/../mocks/new_carset.json';

        if (!file_exists($jsonPath)) {
            throw new RuntimeException("Car dataset JSON file not found: $jsonPath");
        }

        $jsonContent = file_get_contents($jsonPath);
        if ($jsonContent === false) {
            throw new RuntimeException("Failed to read car dataset JSON file: $jsonPath");
        }

        $dataset = json_decode($jsonContent, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new RuntimeException("Invalid JSON in car dataset file: " . json_last_error_msg());
        }

        if (!is_array($dataset)) {
            throw new RuntimeException("Car dataset JSON root must be an array");
        }
    }

    return $dataset;
}

/**
 * Parse price string to float
 */
function json_parse_price(string $price): float {
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
 * Get all brands/manufacturers
 */
function json_get_brands(): array {
    $dataset = load_car_dataset();
    $brands = [];
    $seen = [];

    foreach ($dataset as $car) {
        $brandName = trim($car['make']);
        if (!in_array(strtolower($brandName), array_map('strtolower', $seen))) {
            $seen[] = $brandName;
            $brands[] = [
                'id' => count($brands) + 1, // Generate sequential ID
                'name' => $brandName,
                'slug' => strtolower(str_replace(' ', '-', $brandName)),
                'country' => 'India', // Default for Indian market
                'logo' => null, // No logo in JSON
                'model_count' => 0, // Will be calculated below
                'min_price' => null,
                'max_price' => null
            ];
        }
    }

    // Calculate model counts and price ranges
    foreach ($brands as &$brand) {
        $brandModels = json_get_models_by_brand($brand['name']);
        $brand['model_count'] = count($brandModels);

        if (!empty($brandModels)) {
            $prices = [];
            foreach ($brandModels as $model) {
                foreach ($model['variants'] as $variant) {
                    $prices[] = json_parse_price($variant['price']);
                }
            }
            $brand['min_price'] = min($prices);
            $brand['max_price'] = max($prices);
        }
    }

    // Sort alphabetically
    usort($brands, fn($a, $b) => strcmp($a['name'], $b['name']));

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
        if (strcasecmp(trim($car['make']), $brandName) === 0) {
            $modelName = trim($car['model']);
            if (!in_array(strtolower($modelName), array_map('strtolower', $seen))) {
                $seen[] = $modelName;

                // Get variants for this model
                $variants = [];
                foreach ($dataset as $car2) {
                    if (strcasecmp(trim($car2['make']), $brandName) === 0 &&
                        strcasecmp(trim($car2['model']), $modelName) === 0) {
                        foreach ($car2['variants'] as $variant) {
                            $variants[] = [
                                'id' => count($variants) + 1,
                                'name' => trim($variant['name']),
                                'fuel_type' => trim($variant['fuel_type']),
                                'transmission' => trim($variant['transmission'] ?? 'Manual'),
                                'price' => trim($variant['price']),
                                'price_numeric' => json_parse_price($variant['price']),
                                'engine_size' => trim($variant['engine_size'] ?? ''),
                                'horsepower' => trim($variant['horsepower'] ?? '')
                            ];
                        }
                    }
                }

                // Sort variants by price
                usort($variants, fn($a, $b) => $a['price_numeric'] <=> $b['price_numeric']);

                $models[] = [
                    'id' => count($models) + 1,
                    'name' => $modelName,
                    'slug' => strtolower(str_replace(' ', '-', $modelName)),
                    'brand' => $brandName,
                    'segment' => trim($car['segment']),
                    'launch_year' => 2023, // Default
                    'variants' => $variants,
                    'variant_count' => count($variants),
                    'fuel_types' => array_unique(array_column($variants, 'fuel_type')),
                    'price_range' => [
                        'min' => !empty($variants) ? min(array_column($variants, 'price_numeric')) : 0,
                        'max' => !empty($variants) ? max(array_column($variants, 'price_numeric')) : 0
                    ],
                    'image' => null // No image in JSON
                ];
            }
        }
    }

    // Sort models alphabetically
    usort($models, fn($a, $b) => strcmp($a['name'], $b['name']));

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
        if (strcasecmp(trim($car['model']), $modelName) === 0) {
            foreach ($car['variants'] as $variant) {
                $variants[] = [
                    'id' => count($variants) + 1,
                    'name' => trim($variant['name']),
                    'model' => $modelName,
                    'brand' => trim($car['make']),
                    'fuel_type' => trim($variant['fuel_type']),
                    'transmission' => trim($variant['transmission'] ?? 'Manual'),
                    'price' => trim($variant['price']),
                    'price_numeric' => json_parse_price($variant['price']),
                    'engine_size' => trim($variant['engine_size'] ?? ''),
                    'horsepower' => trim($variant['horsepower'] ?? ''),
                    'segment' => trim($car['segment'])
                ];
            }
        }
    }

    // Sort by price
    usort($variants, fn($a, $b) => $a['price_numeric'] <=> $b['price_numeric']);

    return $variants;
}

/**
 * Search cars with filters
 */
function json_search(array $filters = []): array {
    $dataset = load_car_dataset();
    $results = [];

    foreach ($dataset as $car) {
        foreach ($car['variants'] as $variant) {
            $match = true;

            // Brand filter
            if (!empty($filters['brand']) && strcasecmp(trim($car['make']), trim($filters['brand'])) !== 0) {
                $match = false;
            }

            // Model filter
            if (!empty($filters['model']) && strcasecmp(trim($car['model']), trim($filters['model'])) !== 0) {
                $match = false;
            }

            // Fuel type filter
            if (!empty($filters['fuel_type'])) {
                $fuelTypes = is_array($filters['fuel_type']) ? $filters['fuel_type'] : [$filters['fuel_type']];
                if (!in_array(trim($variant['fuel_type']), array_map('trim', $fuelTypes))) {
                    $match = false;
                }
            }

            // Transmission filter
            if (!empty($filters['transmission'])) {
                $transmissions = is_array($filters['transmission']) ? $filters['transmission'] : [$filters['transmission']];
                $variantTransmission = trim($variant['transmission'] ?? 'Manual');
                if (!in_array($variantTransmission, array_map('trim', $transmissions))) {
                    $match = false;
                }
            }

            // Price range filter
            if ($match && (!empty($filters['min_price']) || !empty($filters['max_price']))) {
                $price = json_parse_price($variant['price']);
                if (!empty($filters['min_price']) && $price < (float) $filters['min_price']) {
                    $match = false;
                }
                if (!empty($filters['max_price']) && $price > (float) $filters['max_price']) {
                    $match = false;
                }
            }

            // Text search
            if (!empty($filters['search'])) {
                $search = strtolower(trim($filters['search']));
                $searchable = strtolower($car['make'] . ' ' . $car['model'] . ' ' . $car['segment'] . ' ' . $variant['name']);
                if (strpos($searchable, $search) === false) {
                    $match = false;
                }
            }

            if ($match) {
                $results[] = [
                    'id' => count($results) + 1,
                    'brand' => trim($car['make']),
                    'model' => trim($car['model']),
                    'variant' => trim($variant['name']),
                    'segment' => trim($car['segment']),
                    'fuel_type' => trim($variant['fuel_type']),
                    'transmission' => trim($variant['transmission'] ?? 'Manual'),
                    'price' => trim($variant['price']),
                    'price_numeric' => json_parse_price($variant['price']),
                    'engine_size' => trim($variant['engine_size'] ?? ''),
                    'horsepower' => trim($variant['horsepower'] ?? '')
                ];
            }
        }
    }

    // Sorting
    $sortBy = $filters['sort_by'] ?? 'price_asc';
    switch ($sortBy) {
        case 'price_desc':
            usort($results, fn($a, $b) => $b['price_numeric'] <=> $a['price_numeric']);
            break;
        case 'name_asc':
            usort($results, fn($a, $b) => strcmp($a['model'], $b['model']));
            break;
        case 'name_desc':
            usort($results, fn($a, $b) => strcmp($b['model'], $a['model']));
            break;
        default: // price_asc
            usort($results, fn($a, $b) => $a['price_numeric'] <=> $b['price_numeric']);
    }

    // Pagination
    $limit = $filters['limit'] ?? 20;
    $offset = $filters['offset'] ?? 0;

    return array_slice($results, $offset, $limit);
}

/**
 * Get car by ID or slug
 */
function json_get_car(string|int $identifier): ?array {
    $dataset = load_car_dataset();

    // Try by ID (if numeric)
    if (is_numeric($identifier)) {
        $id = (int) $identifier;
        $counter = 1;
        foreach ($dataset as $car) {
            foreach ($car['variants'] as $variant) {
                if ($counter === $id) {
                    return [
                        'id' => $id,
                        'brand' => trim($car['make']),
                        'model' => trim($car['model']),
                        'variant' => trim($variant['name']),
                        'segment' => trim($car['segment']),
                        'fuel_type' => trim($variant['fuel_type']),
                        'transmission' => trim($variant['transmission'] ?? 'Manual'),
                        'price' => trim($variant['price']),
                        'price_numeric' => json_parse_price($variant['price']),
                        'engine_size' => trim($variant['engine_size'] ?? ''),
                        'horsepower' => trim($variant['horsepower'] ?? ''),
                        'specs' => [] // No specs in JSON
                    ];
                }
                $counter++;
            }
        }
    }

    // Try by slug (brand-model-variant format)
    $slug = trim($identifier);
    foreach ($dataset as $car) {
        foreach ($car['variants'] as $variant) {
            $expectedSlug = strtolower(str_replace(' ', '-', $car['make'] . '-' . $car['model'] . '-' . $variant['name']));
            if ($expectedSlug === strtolower($slug)) {
                return [
                    'id' => 1, // Placeholder
                    'brand' => trim($car['make']),
                    'model' => trim($car['model']),
                    'variant' => trim($variant['name']),
                    'segment' => trim($car['segment']),
                    'fuel_type' => trim($variant['fuel_type']),
                    'transmission' => trim($variant['transmission'] ?? 'Manual'),
                    'price' => trim($variant['price']),
                    'price_numeric' => json_parse_price($variant['price']),
                    'engine_size' => trim($variant['engine_size'] ?? ''),
                    'horsepower' => trim($variant['horsepower'] ?? ''),
                    'specs' => [] // No specs in JSON
                ];
            }
        }
    }

    return null;
}
