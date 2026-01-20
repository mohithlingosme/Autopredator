<?php

require_once __DIR__ . '/../app/Repositories/SchemaNormalizer.php';

use App\Repositories\SchemaNormalizer;

echo "Starting normalization process...\n";

$startTime = microtime(true);

$rawTxtPath = __DIR__ . '/../data/raw/data.original.txt';
$rawJsonPath = __DIR__ . '/../data/raw/XUV700.json';

$normalizedDir = __DIR__ . '/../data/normalized';
if (!is_dir($normalizedDir)) {
    mkdir($normalizedDir, 0777, true);
}

$brands = [];
$models = [];
$variants = [];

// --- P7: Process a limited set of brands for MVP ---
$mvpBrands = ['Hyundai', 'Mahindra', 'Tata', 'Toyota', 'Honda'];
$currentMake = '';

$fileHandle = fopen($rawTxtPath, 'r');
if ($fileHandle) {
    fgetcsv($fileHandle, 0, "\t"); // Skip header
    while (($line = fgetcsv($fileHandle, 0, "\t")) !== false) {
        if (count($line) < 7) {
            if (!empty(trim($line[0])) && !is_numeric($line[0])) {
                 $currentMake = trim($line[0]);
            }
            continue;
        }

        $make = trim($line[1]);
        if (!in_array($make, $mvpBrands)) {
            continue; // Skip brands not in our MVP list
        }

        // 1. Normalize Brand
        $brandSlug = SchemaNormalizer::toSlug($make);
        if (!isset($brands[$brandSlug])) {
            $brands[$brandSlug] = [
                'slug' => $brandSlug,
                'name' => $make,
                'country_of_origin' => 'Unknown', // Default
                'logo_url' => null,
            ];
        }

        // 2. Normalize Model
        $modelName = trim($line[2]);
        $modelSlug = SchemaNormalizer::toSlug($make . ' ' . $modelName);
        
        list($minPrice, $maxPrice) = SchemaNormalizer::parsePriceRangeToRupees(trim($line[3]));
        list($minPower, $maxPower) = SchemaNormalizer::extractNumericRange(trim($line[4]));

        if (!isset($models[$modelSlug])) {
            $models[$modelSlug] = [
                'slug' => $modelSlug,
                'brand_slug' => $brandSlug,
                'name' => $modelName,
                'launch_year' => null,
                'body_type' => 'Unknown', // Placeholder
                'status' => str_contains(strtolower($line[7]), 'discontinued') ? 'DISCONTINUED' : 'CURRENT',
                'price_ex_showroom_min_rupees' => $minPrice,
                'price_ex_showroom_max_rupees' => $maxPrice,
                'fuel_types' => SchemaNormalizer::toStringArray(trim($line[6])),
                'transmission_types' => [], // To be aggregated from variants
                'seating_capacities' => [], // To be aggregated from variants
                'image_url' => null,
            ];
        }

        // 3. Normalize a single Variant from the model row
        $variantName = $modelName . ' Base';
        $variantSlug = SchemaNormalizer::toSlug($make . ' ' . $variantName);
        
        $variants[$variantSlug] = [
            'slug' => $variantSlug,
            'model_slug' => $modelSlug,
            'name' => $variantName,
            'price_ex_showroom_rupees' => $minPrice,
            'price_on_road_rupees' => null,
            'fuel_type' => SchemaNormalizer::toStringArray(trim($line[6]))[0] ?? 'Unknown',
            'transmission' => 'Manual', // Default assumption
            'seating_capacity' => null,
            'mileage_claim_kmpl' => SchemaNormalizer::extractNumericRange(trim($line[5]))[0],
            'mileage_claim_km_charge' => null,
            'specs' => [
                'max_power_bhp' => $minPower,
            ],
            'features' => [],
        ];
    }
    fclose($fileHandle);
}

// Process detailed XUV700 JSON
$xuv700Data = json_decode(file_get_contents($rawJsonPath), true);
if ($xuv700Data) {
    $modelData = $xuv700Data[0];
    $brandName = $modelData['manufacturer']['name'];
    $modelName = $modelData['model']['name'];
    $brandSlug = SchemaNormalizer::toSlug($brandName);
    $modelSlug = SchemaNormalizer::toSlug($brandName . ' ' . $modelName);

    // Update model with more accurate data
    $models[$modelSlug]['launch_year'] = $modelData['model']['launch_year'];
    $models[$modelSlug]['body_type'] = $modelData['model']['body_type'];
    
    foreach ($xuv700Data as $variantData) {
        $variantName = $variantData['variant']['name'];
        $variantSlug = SchemaNormalizer::toSlug($brandName . ' ' . $modelName . ' ' . $variantName);
        
        $variants[$variantSlug] = [
            'slug' => $variantSlug,
            'model_slug' => $modelSlug,
            'name' => $variantName,
            'price_ex_showroom_rupees' => SchemaNormalizer::toIntOrNull($variantData['variant']['ex_showroom_price']),
            'price_on_road_rupees' => SchemaNormalizer::toIntOrNull($variantData['variant']['on_road_price']),
            'fuel_type' => $variantData['variant']['fuel_type'],
            'transmission' => $variantData['variant']['transmission'],
            'seating_capacity' => SchemaNormalizer::toIntOrNull($variantData['model']['Seating Capacity'] ?? 5),
            'mileage_claim_kmpl' => SchemaNormalizer::extractNumericRange($variantData['variant']['mileage_claim'])[0],
            'mileage_claim_km_charge' => null,
            'specs' => [
                'engine_displacement_cc' => SchemaNormalizer::toIntOrNull($variantData['specs']['engine_displacement_cc']),
                'max_power_bhp' => SchemaNormalizer::extractNumericRange($variantData['specs']['max_power_bhp'])[0],
                'max_torque_nm' => SchemaNormalizer::extractNumericRange($variantData['specs']['max_torque_nm'])[0],
                'wheelbase_mm' => SchemaNormalizer::toIntOrNull($variantData['specs']['wheelbase_mm']),
            ],
            'features' => ['air_conditioner', 'power_windows', 'central_locking'], // Example
        ];
    }
}


file_put_contents($normalizedDir . '/brands.json', json_encode(array_values($brands), JSON_PRETTY_PRINT));
file_put_contents($normalizedDir . '/models.json', json_encode(array_values($models), JSON_PRETTY_PRINT));
file_put_contents($normalizedDir . '/variants.json', json_encode(array_values($variants), JSON_PRETTY_PRINT));

$endTime = microtime(true);
$duration = round($endTime - $startTime, 2);

echo "Normalization complete in {$duration}s.\n";
echo "-------------------------------------\n";
echo "Brands: " . count($brands) . "\n";
echo "Models: " . count($models) . "\n";
echo "Variants: " . count($variants) . "\n";