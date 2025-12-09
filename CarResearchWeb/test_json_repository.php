<?php
declare(strict_types=1);

require_once 'includes/json_car_repository.php';

// Test 1: Load car dataset
echo "Test 1: Loading car dataset\n";
try {
    $data = load_car_dataset();
    echo "✓ JSON data loaded successfully. Count: " . count($data) . "\n";
} catch (Exception $e) {
    echo "✗ Failed to load JSON data: " . $e->getMessage() . "\n";
}

// Test 2: Get brands
echo "\nTest 2: Get brands\n";
$brands = json_get_brands();
echo "✓ Found " . count($brands) . " brands\n";
if (count($brands) > 0) {
    echo "First brand: " . $brands[0]['name'] . "\n";
}

// Test 3: Get models by brand
echo "\nTest 3: Get models by brand\n";
if (count($brands) > 0) {
    $models = json_get_models_by_brand($brands[0]['name']);
    echo "✓ Found " . count($models) . " models for " . $brands[0]['name'] . "\n";
    if (count($models) > 0) {
        echo "First model: " . $models[0]['name'] . "\n";
    }
}

// Test 4: Get variants by model
echo "\nTest 4: Get variants by model\n";
if (!empty($models)) {
    $variants = json_get_variants_by_model($models[0]['name']);
    echo "✓ Found " . count($variants) . " variants for model " . $models[0]['name'] . "\n";
    if (count($variants) > 0) {
        echo "First variant: " . $variants[0]['name'] . " - " . $variants[0]['price'] . "\n";
    }
}

// Test 5: Search cars
echo "\nTest 5: Search cars\n";
$searchFilters = ['limit' => 5];
$searchResults = json_search($searchFilters);
echo "✓ Search results: " . count($searchResults) . " cars found\n";
if (count($searchResults) > 0) {
    echo "First result: " . $searchResults[0]['make'] . " " . $searchResults[0]['model'] . " " . $searchResults[0]['variants'][0]['name'] . "\n";
}

// Test 6: Get car by ID
echo "\nTest 6: Get car by ID\n";
$car = json_get_car(1);
if ($car) {
    echo "✓ Car ID 1: " . $car['make'] . " " . $car['model'] . "\n";
} else {
    echo "✗ Car ID 1 not found\n";
}

echo "\n=== JSON Repository tests completed ===\n";
?>
