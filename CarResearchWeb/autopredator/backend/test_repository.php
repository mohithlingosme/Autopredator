<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

echo "Testing Repository...\n";

try {
    $brands = get_all_manufacturers();
    echo "Found " . count($brands) . " manufacturers\n";

    if (!empty($brands)) {
        $firstBrand = $brands[0];
        echo "First brand: " . $firstBrand['name'] . "\n";

        $models = car_service()->getModelsByBrand($firstBrand['name']);
        echo "Found " . count($models) . " models for " . $firstBrand['name'] . "\n";

        if (!empty($models)) {
            $firstModel = $models[0];
            echo "First model: " . ($firstModel['model'] ?? 'N/A') . "\n";

            $variants = car_service()->getVariantsByModel($firstModel['model'] ?? '');
            echo "Found " . count($variants) . " variants\n";

            if (!empty($variants)) {
                $firstVariant = $variants[0];
                echo "First variant: " . ($firstVariant['name'] ?? 'N/A') . "\n";
            }
        }
    }

    echo "\nAll tests passed!\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
