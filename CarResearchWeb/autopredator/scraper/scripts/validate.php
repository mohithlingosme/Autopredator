<?php

echo "Starting validation...\n";
$errors = [];

$normalizedDir = __DIR__ . '/../data/normalized';
$dictionariesDir = __DIR__ . '/../data/dictionaries';

// 1. Load all data
$brands = json_decode(file_get_contents($normalizedDir . '/brands.json'), true);
$models = json_decode(file_get_contents($normalizedDir . '/models.json'), true);
$variants = json_decode(file_get_contents($normalizedDir . '/variants.json'), true);
$specDict = json_decode(file_get_contents($dictionariesDir . '/specs.json'), true);
$featureDict = json_decode(file_get_contents($dictionariesDir . '/features.json'), true);

if (!$brands || !$models || !$variants || !$specDict || !$featureDict) {
    die("FATAL: Could not read one or more JSON data files. Exiting.\n");
}

// 2. Create lookup maps for efficiency
$brandSlugs = array_column($brands, 'slug');
$modelSlugs = array_column($models, 'slug');
$specKeys = array_column($specDict, 'key');
$featureKeys = array_column($featureDict, 'key');

// 3. Validate slug uniqueness
if (count($brandSlugs) !== count(array_unique($brandSlugs))) {
    $errors[] = "Duplicate brand slugs found.";
}
if (count($modelSlugs) !== count(array_unique($modelSlugs))) {
    $errors[] = "Duplicate model slugs found.";
}
$variantSlugs = array_column($variants, 'slug');
if (count($variantSlugs) !== count(array_unique($variantSlugs))) {
    $errors[] = "Duplicate variant slugs found.";
}

// 4. Validate relationships
foreach ($models as $model) {
    if (!in_array($model['brand_slug'], $brandSlugs)) {
        $errors[] = "Model '{$model['slug']}' has broken relationship: brand '{$model['brand_slug']}' not found.";
    }
    if (empty($model['name'])) {
        $errors[] = "Model '{$model['slug']}' has an empty name.";
    }
}

foreach ($variants as $variant) {
    if (!in_array($variant['model_slug'], $modelSlugs)) {
        $errors[] = "Variant '{$variant['slug']}' has broken relationship: model '{$variant['model_slug']}' not found.";
    }

    // 5. Validate variant fields
    if (!is_int($variant['price_ex_showroom_rupees']) && $variant['price_ex_showroom_rupees'] !== null) {
        $errors[] = "Variant '{$variant['slug']}' has invalid type for 'price_ex_showroom_rupees'. Expected int|null.";
    }

    if (!is_string($variant['fuel_type'])) {
        $errors[] = "Variant '{$variant['slug']}' has invalid type for 'fuel_type'. Expected string.";
    }

    // 6. Validate against dictionaries
    if (isset($variant['specs'])) {
        foreach (array_keys($variant['specs']) as $specKey) {
            if (!in_array($specKey, $specKeys)) {
                $errors[] = "Variant '{$variant['slug']}' has unknown spec key: '{$specKey}'.";
            }
        }
    }

    if (isset($variant['features'])) {
        foreach ($variant['features'] as $featureKey) {
            if (!in_array($featureKey, $featureKeys)) {
                $errors[] = "Variant '{$variant['slug']}' has unknown feature key: '{$featureKey}'.";
            }
        }
    }
}

echo "-------------------------\n";
if (empty($errors)) {
    echo "✅ Validation successful. All checks passed.\n";
    exit(0);
} else {
    echo "❌ Validation failed with " . count($errors) . " errors:\n";
    foreach ($errors as $error) {
        echo " - " . $error . "\n";
    }
    exit(1);
}

?>