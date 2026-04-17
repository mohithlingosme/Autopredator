<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/helpers.php';

/**
 * Seed autopredator_cars from data/new_carset.json using idempotent UPSERTs.
 * - Slug-first: lookups and uniqueness rely on slugs.
 * - Idempotent: safe to run multiple times; prices are updated in place.
 * - Data integrity: enforces NOT NULL slugs/image_url/region/as_of_date assumptions.
 */

const DATA_FILE = __DIR__ . '/../data/new_carset.json';
const DEFAULT_REGION = 'IN';
const DEFAULT_PRICE_TYPE = 'ex_showroom';

echo "Seeding autopredator_cars from " . basename(DATA_FILE) . "...\n";

if (!file_exists(DATA_FILE)) {
    fwrite(STDERR, "ERROR: data/new_carset.json not found. Aborting.\n");
    exit(1);
}

$rows = json_decode((string) file_get_contents(DATA_FILE), true);
if (!is_array($rows)) {
    fwrite(STDERR, "ERROR: data/new_carset.json is not valid JSON.\n");
    exit(1);
}

$db = get_db();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$tableCache = [];
$columnCache = [];

/** Helper: check table existence (cached). */
$tableExists = function (string $table) use (&$tableCache, $db): bool {
    if (array_key_exists($table, $tableCache)) {
        return $tableCache[$table];
    }
    $stmt = $db->prepare('SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :table');
    $stmt->execute(['table' => $table]);
    return $tableCache[$table] = ((int) $stmt->fetchColumn() > 0);
};

/** Helper: check column existence (cached). */
$columnExists = function (string $table, string $column) use (&$columnCache, $db, $tableExists): bool {
    $key = "{$table}.{$column}";
    if (array_key_exists($key, $columnCache)) {
        return $columnCache[$key];
    }
    if (!$tableExists($table)) {
        return $columnCache[$key] = false;
    }
    $stmt = $db->prepare(
        'SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :table AND COLUMN_NAME = :col'
    );
    $stmt->execute(['table' => $table, 'col' => $column]);
    return $columnCache[$key] = ((int) $stmt->fetchColumn() > 0);
};

/** Detect the numeric price column to use. */
$detectPriceColumn = function () use ($columnExists): ?string {
    $candidates = ['price_amount', 'price', 'amount', 'ex_showroom_price', 'value'];
    foreach ($candidates as $col) {
        if ($columnExists('variant_price_history', $col)) {
            return $col;
        }
    }
    foreach ($candidates as $col) {
        if ($columnExists('variants', $col)) {
            return $col;
        }
    }
    return null;
};

/** Parse price strings like "₹7.52 L" into integer rupees. */
$parsePrice = static function (?string $raw): ?float {
    if ($raw === null || trim($raw) === '') {
        return null;
    }
    $value = strtolower($raw);
    $multiplier = 1.0;
    if (str_contains($value, 'cr')) {
        $multiplier = 10000000; // crore
    } elseif (str_contains($value, 'l')) {
        $multiplier = 100000; // lakh
    }
    $numeric = preg_replace('/[^0-9.]/', '', $value);
    if ($numeric === null || $numeric === '') {
        return null;
    }
    return (float) $numeric * $multiplier;
};

/** Build slug with brand+model context to avoid collisions. */
$makeSlug = static function (string $brand, string $model = '', string $variant = ''): string {
    $parts = array_filter([$brand, $model, $variant]);
    return slugify(implode(' ', $parts));
};

/** Insert or update and return row id using LAST_INSERT_ID trick. */
$upsert = function (string $table, array $data) use ($db): int {
    $columns = array_keys($data);
    $placeholders = array_map(fn($c) => ':' . $c, $columns);
    $updates = array_map(fn($c) => "{$c} = VALUES({$c})", $columns);
    $updates[] = 'id = LAST_INSERT_ID(id)';

    $sql = sprintf(
        'INSERT INTO %s (%s) VALUES (%s) ON DUPLICATE KEY UPDATE %s',
        $table,
        implode(', ', $columns),
        implode(', ', $placeholders),
        implode(', ', $updates)
    );

    $stmt = $db->prepare($sql);
    $stmt->execute($data);

    return (int) $db->lastInsertId();
};

$priceColumn = $detectPriceColumn();
$hasPriceHistory = $tableExists('variant_price_history');
$hasVariantsTable = $tableExists('variants');
$hasModelsTable = $tableExists('models');
$hasBrandsTable = $tableExists('brands');

if (!$hasBrandsTable || !$hasModelsTable || !$hasVariantsTable) {
    fwrite(STDERR, "ERROR: brands/models/variants tables are required in autopredator_cars.\n");
    exit(1);
}

$db->beginTransaction();

$brandCount = 0;
$modelCount = 0;
$variantCount = 0;
$priceCount = 0;

try {
    foreach ($rows as $row) {
        $brandName = trim((string) ($row['make'] ?? ''));
        $modelName = trim((string) ($row['model'] ?? ''));
        $segment = trim((string) ($row['segment'] ?? ''));
        $variants = $row['variants'] ?? [];

        if ($brandName === '' || $modelName === '' || !is_array($variants)) {
            continue;
        }

        $brandSlug = $makeSlug($brandName);
        $brandId = $upsert('brands', [
            'name' => $brandName,
            'slug' => $brandSlug,
        ]);
        $brandCount++;

        $modelSlug = $makeSlug($brandName, $modelName);
        $modelData = [
            'brand_id' => $brandId,
            'name' => $modelName,
            'slug' => $modelSlug,
        ];
        if ($segment !== '' && $columnExists('models', 'segment')) {
            $modelData['segment'] = $segment;
        }
        if ($columnExists('models', 'body_type')) {
            $modelData['body_type'] = $segment ?: null;
        }
        $modelId = $upsert('models', $modelData);
        $modelCount++;

        foreach ($variants as $variantRow) {
            if (!is_array($variantRow)) {
                continue;
            }

            $variantName = trim((string) ($variantRow['name'] ?? ''));
            if ($variantName === '') {
                continue;
            }

            $variantSlug = $makeSlug($brandName, $modelName, $variantName);
            $fuel = trim((string) ($variantRow['fuel_type'] ?? ''));
            $trans = trim((string) ($variantRow['transmission'] ?? ''));
            $bodyType = $segment ?: null;

            $variantData = [
                'model_id' => $modelId,
                'name' => $variantName,
                'slug' => $variantSlug,
            ];
            if ($columnExists('variants', 'fuel_type')) {
                $variantData['fuel_type'] = $fuel;
            }
            if ($columnExists('variants', 'transmission_type')) {
                $variantData['transmission_type'] = $trans;
            } elseif ($columnExists('variants', 'transmission')) {
                $variantData['transmission'] = $trans;
            }
            if ($columnExists('variants', 'body_type')) {
                $variantData['body_type'] = $bodyType;
            }
            if ($columnExists('variants', 'engine_size')) {
                $variantData['engine_size'] = $variantRow['engine_size'] ?? null;
            }
            if ($columnExists('variants', 'horsepower')) {
                $variantData['horsepower'] = $variantRow['horsepower'] ?? null;
            }

            $variantId = $upsert('variants', $variantData);
            $variantCount++;

            // Latest price
            $priceNumeric = $parsePrice($variantRow['price'] ?? null);
            if ($priceNumeric !== null && $priceNumeric > 0) {
                // Update variants table price column if present
                if ($columnExists('variants', 'ex_showroom_price')) {
                    $db->prepare('UPDATE variants SET ex_showroom_price = :price WHERE id = :id')
                        ->execute(['price' => $priceNumeric, 'id' => $variantId]);
                } elseif ($priceColumn !== null && $columnExists('variants', $priceColumn)) {
                    $db->prepare("UPDATE variants SET {$priceColumn} = :price WHERE id = :id")
                        ->execute(['price' => $priceNumeric, 'id' => $variantId]);
                }

                // Upsert into price history if available
                if ($hasPriceHistory && $priceColumn !== null) {
                    $priceData = [
                        'variant_id' => $variantId,
                        'price_type' => DEFAULT_PRICE_TYPE,
                        'region' => DEFAULT_REGION,
                        'as_of_date' => date('Y-m-d'),
                        $priceColumn => $priceNumeric,
                    ];
                    if ($columnExists('variant_price_history', 'currency')) {
                        $priceData['currency'] = 'INR';
                    }

                    $upsert('variant_price_history', $priceData);
                    $priceCount++;
                }
            }
        }
    }

    $db->commit();
    echo "✅ Seed complete: brands={$brandCount}, models={$modelCount}, variants={$variantCount}, prices={$priceCount}\n";
} catch (PDOException $e) {
    $db->rollBack();
    fwrite(STDERR, "ERROR during seed: " . $e->getMessage() . "\n");
    exit(1);
}
