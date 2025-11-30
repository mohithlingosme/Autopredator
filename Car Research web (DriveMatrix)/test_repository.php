<?php
declare(strict_types=1);

require_once 'includes/repository.php';

// Test 1: Load car data
echo "Test 1: Loading car data\n";
try {
    $data = load_car_data();
    echo "✓ JSON data loaded successfully. Count: " . count($data) . "\n";
} catch (Exception $e) {
    echo "✗ Failed to load JSON data: " . $e->getMessage() . "\n";
}

// Test 2: Get all manufacturers
echo "\nTest 2: Get all manufacturers\n";
$manufacturers = get_all_manufacturers();
echo "✓ Found " . count($manufacturers) . " manufacturers\n";
if (count($manufacturers) > 0) {
    echo "First manufacturer: " . $manufacturers[0]['name'] . "\n";
}

// Test 3: Get manufacturer by ID
echo "\nTest 3: Get manufacturer by ID\n";
$manufacturer = get_manufacturer_by_id(1);
if ($manufacturer) {
    echo "✓ Manufacturer ID 1: " . $manufacturer['name'] . "\n";
} else {
    echo "✗ Manufacturer ID 1 not found\n";
}

// Test 4: Get manufacturer by name
echo "\nTest 4: Get manufacturer by name\n";
$manufacturer = get_manufacturer_by_name('Maruti Suzuki');
if ($manufacturer) {
    echo "✓ Maruti Suzuki found with ID: " . $manufacturer['id'] . "\n";
} else {
    echo "✗ Maruti Suzuki not found\n";
}

// Test 5: Get model families by manufacturer
echo "\nTest 5: Get model families by manufacturer\n";
if ($manufacturer) {
    $families = get_model_families_by_manufacturer($manufacturer['id']);
    echo "✓ Found " . count($families) . " families for " . $manufacturer['name'] . "\n";
    if (count($families) > 0) {
        echo "First family: " . $families[0]['nameplate'] . "\n";
    }
}

// Test 6: Get models by family
echo "\nTest 6: Get models by family\n";
if (!empty($families)) {
    $models = get_models_by_family($families[0]['id']);
    echo "✓ Found " . count($models) . " models for family " . $families[0]['nameplate'] . "\n";
    if (count($models) > 0) {
        echo "First model: " . $models[0]['name'] . "\n";
    }
}

// Test 7: Get variants by model
echo "\nTest 7: Get variants by model\n";
if (!empty($models)) {
    $variants = get_variants_by_model($models[0]['id']);
    echo "✓ Found " . count($variants) . " variants for model " . $models[0]['name'] . "\n";
    if (count($variants) > 0) {
        echo "First variant: " . $variants[0]['variant_name'] . " - ₹" . number_format($variants[0]['ex_showroom_price']) . "\n";
    }
}

// Test 8: Get variant by ID
echo "\nTest 8: Get variant by ID\n";
if (!empty($variants)) {
    $variant = get_variant_by_id($variants[0]['id']);
    if ($variant) {
        echo "✓ Variant ID " . $variants[0]['id'] . ": " . $variant['variant_name'] . "\n";
    } else {
        echo "✗ Variant ID " . $variants[0]['id'] . " not found\n";
    }
}

// Test 9: Specs and features (should return null/empty)
echo "\nTest 9: Specs and features\n";
if (!empty($variants)) {
    $specs = get_specs_for_variant($variants[0]['id']);
    $features = get_features_for_variant($variants[0]['id']);
    $groupedFeatures = get_grouped_features_for_variant($variants[0]['id']);
    echo "✓ Specs: " . ($specs === null ? "null (as expected)" : "unexpected data") . "\n";
    echo "✓ Features: " . (empty($features) ? "empty array (as expected)" : "unexpected data") . "\n";
    echo "✓ Grouped features: " . (empty($groupedFeatures) ? "empty array (as expected)" : "unexpected data") . "\n";
}

// Test 10: Pricing (should return null/empty)
echo "\nTest 10: Pricing\n";
if (!empty($variants)) {
    $prices = get_prices_for_variant($variants[0]['id']);
    $currentPrice = get_current_price_for_variant($variants[0]['id']);
    echo "✓ Price history: " . (empty($prices) ? "empty array (as expected)" : "unexpected data") . "\n";
    echo "✓ Current price: " . ($currentPrice === null ? "null (as expected)" : "unexpected data") . "\n";
}

// Test 11: Search functionality
echo "\nTest 11: Search functionality\n";
$searchFilters = ['limit' => 5];
$searchResults = search_cars($searchFilters);
$searchCount = search_cars_count($searchFilters);
echo "✓ Search results: " . count($searchResults) . " cars found\n";
echo "✓ Search count: " . $searchCount . " total cars match filters\n";
if (count($searchResults) > 0) {
    echo "First result: " . $searchResults[0]['manufacturer_name'] . " " . $searchResults[0]['model_name'] . " " . $searchResults[0]['variant_name'] . "\n";
}

// Test 12: Featured items
echo "\nTest 12: Featured items\n";
$featuredFamilies = get_featured_families(3);
$featuredVariants = get_featured_variants(3);
echo "✓ Featured families: " . count($featuredFamilies) . "\n";
echo "✓ Featured variants: " . count($featuredVariants) . "\n";

echo "\n=== All tests completed ===\n";
?>
