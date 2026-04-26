<?php
declare(strict_types=1);

/**
 * JSON to MySQL Database Import Script
 *
 * Imports car data from JSON file into the MySQL database.
 * Handles data transformation, validation, and maintains referential integrity.
 */

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/json_car_repository.php';

class JsonToDbImporter
{
    private PDO $pdo;
    private array $jsonData;

    public function __construct(PDO $pdo, array $jsonData)
    {
        $this->pdo = $pdo;
        $this->jsonData = $jsonData;
    }

    public function import(): array
    {
        $stats = [
            'manufacturers' => 0,
            'model_families' => 0,
            'models' => 0,
            'variants' => 0,
            'specs' => 0,
            'errors' => []
        ];

        try {
            $this->pdo->beginTransaction();

            // Import manufacturers
            $manufacturerMap = $this->importManufacturers($stats);

            // Import model families and models
            $modelMap = $this->importModelFamiliesAndModels($manufacturerMap, $stats);

            // Import variants and specs
            $this->importVariantsAndSpecs($modelMap, $stats);

            $this->pdo->commit();

        } catch (Exception $e) {
            $this->pdo->rollBack();
            $stats['errors'][] = "Import failed: " . $e->getMessage();
        }

        return $stats;
    }

    private function importManufacturers(array &$stats): array
    {
        $manufacturerMap = [];
        $manufacturers = [];

        // Extract unique manufacturers from JSON
        foreach ($this->jsonData as $car) {
            $make = trim((string) ($car['make'] ?? ''));
            if ($make !== '' && !in_array($make, $manufacturers, true)) {
                $manufacturers[] = $make;
            }
        }

        $stmt = $this->pdo->prepare("
            INSERT INTO manufacturers (name, slug, country, is_active)
            VALUES (?, ?, 'India', 1)
            ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)
        ");

        foreach ($manufacturers as $manufacturer) {
            $slug = strtolower(str_replace(' ', '-', $manufacturer));
            $stmt->execute([$manufacturer, $slug]);
            $manufacturerMap[$manufacturer] = $this->pdo->lastInsertId();
            $stats['manufacturers']++;
        }

        return $manufacturerMap;
    }

    private function importModelFamiliesAndModels(array $manufacturerMap, array &$stats): array
    {
        $modelMap = [];

        $familyStmt = $this->pdo->prepare("
            INSERT INTO model_families (manufacturer_id, nameplate, slug, body_type, is_active)
            VALUES (?, ?, ?, ?, 1)
            ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)
        ");

        $modelStmt = $this->pdo->prepare("
            INSERT INTO models (family_id, manufacturer_id, name, slug, launch_year, is_active)
            VALUES (?, ?, ?, ?, ?, 1)
            ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)
        ");

        foreach ($this->jsonData as $car) {
            $make = trim((string) ($car['make'] ?? ''));
            $model = trim((string) ($car['model'] ?? ''));
            $segment = trim((string) ($car['segment'] ?? ''));

            if ($make === '' || $model === '' || !isset($manufacturerMap[$make])) {
                continue;
            }

            $manufacturerId = $manufacturerMap[$make];
            $familySlug = strtolower(str_replace(' ', '-', $segment));
            $modelSlug = strtolower(str_replace(' ', '-', $model));

            // Insert model family
            $familyStmt->execute([$manufacturerId, $segment, $familySlug, $segment]);
            $familyId = $this->pdo->lastInsertId();
            $stats['model_families']++;

            // Insert model
            $modelStmt->execute([$familyId, $manufacturerId, $model, $modelSlug, 2023]);
            $modelId = $this->pdo->lastInsertId();
            $stats['models']++;

            $modelMap[$make . '|' . $model] = $modelId;
        }

        return $modelMap;
    }

    private function importVariantsAndSpecs(array $modelMap, array &$stats): void
    {
        $variantStmt = $this->pdo->prepare("
            INSERT INTO variants (model_id, variant_name, slug, fuel_type, transmission, ex_showroom_price, is_active)
            VALUES (?, ?, ?, ?, ?, ?, 1)
        ");

        $specStmt = $this->pdo->prepare("
            INSERT INTO vehicle_specs (variant_id, engine_type, displacement, max_power, max_torque, transmission, fuel_tank_capacity, seating_capacity, ground_clearance, boot_space, fuel_efficiency)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");

        $variantId = 1; // Start from 1 for simplicity

        foreach ($this->jsonData as $car) {
            $make = trim((string) ($car['make'] ?? ''));
            $model = trim((string) ($car['model'] ?? ''));
            $key = $make . '|' . $model;

            if (!isset($modelMap[$key])) {
                continue;
            }

            $modelId = $modelMap[$key];

            foreach (($car['variants'] ?? []) as $variant) {
                $variantName = trim((string) ($variant['name'] ?? ''));
                $fuelType = trim((string) ($variant['fuel_type'] ?? ''));
                $transmission = trim((string) ($variant['transmission'] ?? 'Manual'));
                $price = json_parse_price($variant['price'] ?? '');

                if ($variantName === '') {
                    continue;
                }

                $variantSlug = strtolower(str_replace([' ', '/', '&'], '-', $variantName));

                // Insert variant
                $variantStmt->execute([
                    $modelId,
                    $variantName,
                    $variantSlug,
                    $fuelType,
                    $transmission,
                    $price
                ]);

                $currentVariantId = $this->pdo->lastInsertId();
                $stats['variants']++;

                // Insert specs
                $engineSize = trim((string) ($variant['engine_size'] ?? ''));
                $horsepower = trim((string) ($variant['horsepower'] ?? ''));

                // Parse engine displacement
                $displacement = null;
                if (preg_match('/(\d+)/', $engineSize, $matches)) {
                    $displacement = (int) $matches[1];
                }

                // Parse horsepower
                $maxPower = null;
                if (preg_match('/(\d+)/', $horsepower, $matches)) {
                    $maxPower = (float) $matches[1];
                }

                $specStmt->execute([
                    $currentVariantId,
                    $engineSize,
                    $displacement,
                    $maxPower,
                    null, // max_torque
                    $transmission,
                    null, // fuel_tank_capacity
                    null, // seating_capacity
                    null, // ground_clearance
                    null, // boot_space
                    null  // fuel_efficiency
                ]);

                $stats['specs']++;
            }
        }
    }
}

// Main execution
try {
    echo "Starting JSON to MySQL import...\n";

    // Load JSON data
    $jsonData = load_car_dataset();
    echo "Loaded " . count($jsonData) . " car records from JSON.\n";

    // Initialize database connection
    $pdo = getDbConnection();

    // Create importer and run import
    $importer = new JsonToDbImporter($pdo, $jsonData);
    $stats = $importer->import();

    // Display results
    echo "\nImport completed!\n";
    echo "Manufacturers imported: " . $stats['manufacturers'] . "\n";
    echo "Model families imported: " . $stats['model_families'] . "\n";
    echo "Models imported: " . $stats['models'] . "\n";
    echo "Variants imported: " . $stats['variants'] . "\n";
    echo "Specs imported: " . $stats['specs'] . "\n";

    if (!empty($stats['errors'])) {
        echo "\nErrors encountered:\n";
        foreach ($stats['errors'] as $error) {
            echo "- " . $error . "\n";
        }
    }

} catch (Exception $e) {
    echo "Import failed: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\nImport script completed.\n";

// ── Graphify auto-generation ────────────────────────────────
require_once __DIR__ . '/../../app/Services/GraphifyService.php';
$graphify = new GraphifyService();
$gfResult = $graphify->autoGenerate();

if (!$gfResult['skipped']) {
    if ($gfResult['success']) {
        echo "Graphify graph.json regenerated successfully.\n";
    } else {
        echo "Graphify generation failed: " . $gfResult['error'] . "\n";
    }
} else {
    echo "Graphify auto-generation skipped: " . $gfResult['error'] . "\n";
}
// ─────────────────────────────────────────────────────────────
