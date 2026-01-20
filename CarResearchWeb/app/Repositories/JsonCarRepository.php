<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Data\JsonLoader;
use App\Support\Logger;

/**
 * JSON-backed repository with in-memory caching, validation, and normalization.
 */
class JsonCarRepository implements CarRepositoryInterface
{
    private const FILE_CARSET = 'new_carset.json';
    private const FILE_LEGACY = 'data.json';

    /** @var array<int, array<string, mixed>> */
    private array $dataset = [];

    /** @var array<string, array<int, array<string, mixed>>> keyed by lowercase make */
    private array $modelsByMake = [];

    /** @var array<string, array<string, mixed>> keyed by slug */
    private array $modelSlugMap = [];

    private bool $bootstrapped = false;

    private string $dataDir;

    private JsonLoader $loader;

    public function __construct(string $dataDir, ?JsonLoader $loader = null)
    {
        $this->dataDir = rtrim($dataDir, '/\\');
        $this->loader = $loader ?? new JsonLoader($this->dataDir);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getBrands(): array
    {
        $this->bootstrap();

        $brands = [];
        foreach ($this->modelsByMake as $makeKey => $models) {
            $brandName = $models[0]['make'] ?? $makeKey;
            $allPrices = [];
            foreach ($models as $model) {
                foreach ($model['variants'] as $variant) {
                    if (isset($variant['price_numeric']) && $variant['price_numeric'] > 0) {
                        $allPrices[] = $variant['price_numeric'];
                    }
                }
            }

            $brands[] = [
                'id' => count($brands) + 1,
                'name' => $brandName,
                'slug' => $this->slugify($brandName),
                'country' => 'India',
                'model_count' => count($models),
                'min_price' => $allPrices ? min($allPrices) : null,
                'max_price' => $allPrices ? max($allPrices) : null,
            ];
        }

        usort($brands, static fn($a, $b) => strcmp($a['name'], $b['name']));

        return $brands;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByMake(string $make): array
    {
        $this->bootstrap();

        $key = strtolower(trim($make));
        $models = $this->modelsByMake[$key] ?? [];

        if ($models === [] && $key !== '') {
            foreach ($this->dataset as $row) {
                if (strtolower(trim($row['make'] ?? '')) === $key) {
                    $models[] = $row;
                }
            }
        }

        return $models;
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getModelByName(string $modelName): ?array
    {
        $this->bootstrap();
        $key = strtolower(trim($modelName));

        foreach ($this->dataset as $model) {
            $name = $model['model'] ?? null;
            if (!is_string($name)) {
                continue;
            }
            if (strtolower($name) === $key) {
                return $model;
            }
        }

        return null;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModel(string $modelName): array
    {
        $this->bootstrap();
        $key = strtolower(trim($modelName));

        foreach ($this->dataset as $model) {
            $name = $model['model'] ?? null;
            if (!is_string($name)) {
                continue;
            }

            if (strtolower($name) === $key) {
                $variants = is_array($model['variants'] ?? null) ? $model['variants'] : [];
                return array_map(function ($variant) use ($model) {
                    if (!is_array($variant)) {
                        return $variant;
                    }
                    $variant['id'] = $this->buildVariantId($model, $variant);
                    return $variant;
                }, $variants);
            }
        }

        return [];
    }

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function search(array $filters): array
    {
        $this->bootstrap();

        $results = [];
        $filterBrand = strtolower(trim((string) ($filters['brand'] ?? '')));
        $filterModel = strtolower(trim((string) ($filters['model'] ?? '')));
        $filterSearch = strtolower(trim((string) ($filters['search'] ?? '')));
        $fuelTypes = $this->normalizeArray($filters['fuel_type'] ?? []);
        $transmissions = $this->normalizeArray($filters['transmission'] ?? []);
        $bodyTypes = $this->normalizeArray($filters['body_type'] ?? []);
        $minPrice = isset($filters['min_price']) && $filters['min_price'] !== '' ? (float) $filters['min_price'] : null;
        $maxPrice = isset($filters['max_price']) && $filters['max_price'] !== '' ? (float) $filters['max_price'] : null;

        foreach ($this->dataset as $model) {
            if (!isset($model['variants']) || !is_array($model['variants']) || $model['variants'] === []) {
                continue;
            }

            $modelMake = strtolower(trim((string) ($model['make'] ?? '')));
            $modelName = strtolower(trim((string) ($model['model'] ?? '')));
            $modelSegment = strtolower(trim((string) ($model['segment'] ?? '')));

            foreach ($model['variants'] as $variant) {
                if (!is_array($variant)) {
                    continue;
                }
                $variantName = strtolower(trim((string) ($variant['name'] ?? '')));
                $variantFuel = strtolower(trim((string) ($variant['fuel_type'] ?? '')));
                $variantTransmission = strtolower(trim((string) ($variant['transmission'] ?? '')));
                $variantPrice = (float) ($variant['price_numeric'] ?? 0);

                $match = true;
                if ($filterBrand !== '' && $modelMake !== $filterBrand) {
                    $match = false;
                }
                if ($filterModel !== '' && $modelName !== $filterModel) {
                    $match = false;
                }
                if ($fuelTypes && !in_array($variantFuel, $fuelTypes, true)) {
                    $match = false;
                }
                if ($transmissions && !in_array($variantTransmission, $transmissions, true)) {
                    $match = false;
                }
                if ($bodyTypes && !in_array($modelSegment, $bodyTypes, true)) {
                    $match = false;
                }
                if ($minPrice !== null && $variantPrice < $minPrice) {
                    $match = false;
                }
                if ($maxPrice !== null && $variantPrice > $maxPrice) {
                    $match = false;
                }
                if ($filterSearch !== '') {
                    $haystack = $modelMake . ' ' . $modelName . ' ' . $modelSegment . ' ' . $variantName;
                    if (strpos($haystack, $filterSearch) === false) {
                        $match = false;
                    }
                }

                if ($match) {
                    $results[] = [
                        'id' => $this->buildVariantId($model, $variant),
                        'brand' => $model['make'] ?? '',
                        'model' => $model['model'] ?? '',
                        'variant' => $variant['name'] ?? '',
                        'segment' => $model['segment'] ?? '',
                        'fuel_type' => $variant['fuel_type'] ?? '',
                        'transmission' => $variant['transmission'] ?? '',
                        'price' => $variant['price_raw'] ?? '',
                        'price_numeric' => $variantPrice,
                        'engine_size' => $variant['engine_size'] ?? '',
                        'horsepower' => $variant['horsepower'] ?? '',
                        'power_min' => $variant['power_min'] ?? 0,
                        'power_max' => $variant['power_max'] ?? 0,
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

        $limit = isset($filters['limit']) ? max(1, (int) $filters['limit']) : 12;
        $offset = isset($filters['offset']) ? max(0, (int) $filters['offset']) : 0;

        return array_slice($results, $offset, $limit);
    }

    public function getVariantById(int $id): ?array
    {
        $all = $this->search([
            'limit' => PHP_INT_MAX,
            'offset' => 0,
        ]);

        foreach ($all as $row) {
            if ((int) ($row['id'] ?? 0) === $id) {
                return $row;
            }
        }

        return null;
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getBySlug(string $slug): ?array
    {
        $this->bootstrap();
        $key = strtolower(trim($slug));

        return $this->modelSlugMap[$key] ?? null;
    }

    private function bootstrap(): void
    {
        if ($this->bootstrapped) {
            return;
        }

        $this->dataset = $this->loadNormalizedDataset();
        $this->buildIndexes();
        $this->bootstrapped = true;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadNormalizedDataset(): array
    {
        $models = [];
        $primaryRows = $this->loadJsonFile(self::FILE_CARSET);
        $legacyRows = $this->loadJsonFile(self::FILE_LEGACY);

        foreach ($primaryRows as $rowIndex => $row) {
            $normalized = $this->normalizeCarsetRow($rowIndex, $row);
            if ($normalized !== null) {
                $models[] = $normalized;
            }
        }

        foreach ($legacyRows as $rowIndex => $row) {
            $normalized = $this->normalizeLegacyRow($rowIndex, $row);
            if ($normalized !== null) {
                $models[] = $normalized;
            }
        }

        return $models;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadJsonFile(string $filename): array
    {
        $data = $this->loader->load($filename);
        if (!is_array($data)) {
            return [];
        }

        return $data;
    }

    /**
     * Basic validation for primary dataset rows.
     *
     * @param array<string, mixed> $row
     */
    private function validateCarsetRow(array $row): bool
    {
        if (!isset($row['make'], $row['model'], $row['variants'])) {
            return false;
        }

        if (!is_array($row['variants']) || $row['variants'] === []) {
            return false;
        }

        return true;
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>|null
     */
    private function normalizeCarsetRow(int $index, array $row): ?array
    {
        if (!$this->validateCarsetRow($row)) {
            Logger::channel('repository')->error('Skipping invalid primary row', ['index' => $index, 'row' => $row]);
            return null;
        }

        $make = $this->cleanString($row['make'] ?? '');
        $model = $this->cleanString($row['model'] ?? '');
        $segment = $this->cleanString($row['segment'] ?? '');
        $launchYear = isset($row['launch_year']) ? (int) $row['launch_year'] : null;
        $variantsRaw = $row['variants'] ?? [];

        if ($make === '' || $model === '' || !is_array($variantsRaw) || $variantsRaw === []) {
            Logger::channel('repository')->error('Skipping malformed primary row', ['index' => $index]);
            return null;
        }

        $variants = [];
        foreach ($variantsRaw as $variantIndex => $variant) {
            $name = $this->cleanString($variant['name'] ?? '');
            $priceRaw = $this->cleanString($variant['price'] ?? '');
            $fuel = $this->cleanString($variant['fuel_type'] ?? '');
            if ($name === '' || $fuel === '') {
                Logger::channel('repository')->error('Skipping malformed variant', ['row' => $index, 'variant' => $variantIndex]);
                continue;
            }

            $priceNumeric = $this->parsePrice($priceRaw);
            $powerRange = $this->parsePowerRange($this->cleanString($variant['horsepower'] ?? ''));
            $variants[] = [
                'id' => $variantIndex + 1,
                'name' => $name,
                'brand' => $make,
                'model' => $model,
                'segment' => $segment !== '' ? $segment : 'Car',
                'fuel_type' => $fuel,
                'transmission' => $this->cleanString($variant['transmission'] ?? 'Manual'),
                'price_raw' => $priceRaw,
                'price_numeric' => $priceNumeric,
                'engine_size' => $this->cleanString($variant['engine_size'] ?? ''),
                'horsepower' => $powerRange['min'] !== $powerRange['max'] ? $powerRange['min'] . '-' . $powerRange['max'] : (string) $powerRange['min'],
                'power_min' => $powerRange['min'],
                'power_max' => $powerRange['max'],
            ];
        }

        if ($variants === []) {
            Logger::channel('repository')->error('No valid variants after normalization', ['row' => $index]);
            return null;
        }

        $priceValues = array_column($variants, 'price_numeric');
        return [
            'id' => $row['id'] ?? null,
            'make' => $make,
            'model' => $model,
            'segment' => $segment !== '' ? $segment : 'Car',
            'launch_year' => $launchYear ?: (int) (date('Y')),
            'variants' => $variants,
            'variant_count' => count($variants),
            'fuel_types' => array_values(array_unique(array_map('strtolower', array_column($variants, 'fuel_type')))),
            'price_range' => [
                'min' => $priceValues ? min($priceValues) : 0,
                'max' => $priceValues ? max($priceValues) : 0,
            ],
            'slug' => $this->slugify($make . '-' . $model),
        ];
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>|null
     */
    private function normalizeLegacyRow(int $index, array $row): ?array
    {
        $make = $this->cleanString($row['make'] ?? '');
        $model = $this->cleanString($row['model'] ?? '');
        if ($make === '' || $model === '') {
            return null;
        }

        $priceRaw = $this->cleanString($row['price'] ?? '');
        $range = $this->parsePriceRange($priceRaw);
        $variant = [
            'id' => 1,
            'name' => $model . ' Base',
            'brand' => $make,
            'model' => $model,
            'segment' => $this->cleanString($row['notes'] ?? 'Car'),
            'fuel_type' => $this->cleanString($row['fuel_type'] ?? ''),
            'transmission' => 'Manual',
            'price_raw' => $priceRaw,
            'price_numeric' => $range['min'] ?: $range['max'],
            'engine_size' => '',
            'horsepower' => $this->cleanString($row['power_bhp'] ?? ''),
        ];

        return [
            'id' => $index + 10000, // keep separate namespace
            'make' => $make,
            'model' => $model,
            'segment' => $this->cleanString($row['notes'] ?? 'Car'),
            'launch_year' => isset($row['launch_year']) ? (int) $row['launch_year'] : (int) (date('Y') - 1),
            'variants' => [$variant],
            'variant_count' => 1,
            'fuel_types' => [$variant['fuel_type']],
            'price_range' => $range,
            'slug' => $this->slugify($make . '-' . $model),
        ];
    }

    private function buildIndexes(): void
    {
        foreach ($this->dataset as $model) {
            $makeKey = strtolower(trim($model['make'] ?? ''));
            $modelName = trim($model['model'] ?? '');
            if ($makeKey === '' || $modelName === '') {
                Logger::channel('repository')->error('Skipping model with missing make or model', ['model' => $model]);
                continue;
            }

            $this->modelsByMake[$makeKey] ??= [];
            $this->modelsByMake[$makeKey][] = $model;

            $slugKey = strtolower($model['slug'] ?? $this->slugify($model['make'] . '-' . $model['model']));
            $this->modelSlugMap[$slugKey] = $model;
        }

        foreach ($this->modelsByMake as $make => &$models) {
            usort($models, static fn($a, $b) => strcmp($a['model'], $b['model']));
        }
    }

    private function cleanString(mixed $value): string
    {
        return trim((string) $value);
    }

    private function slugify(string $text): string
    {
        $text = strtolower(trim($text));
        $text = preg_replace('/[^a-z0-9]+/', '-', $text) ?? '';
        $text = trim($text, '-');

        return $text !== '' ? $text : 'n-a';
    }

    private function parsePrice(string $price): float
    {
        $normalized = str_replace(['ƒ' . "'û", '₹', 'Rs.', 'INR', ',', ' '], '', $price);
        $normalized = str_replace(["Lakh", "lakh"], 'L', $normalized);
        if ($normalized === '') {
            return 0.0;
        }

        if (stripos($normalized, 'Cr') !== false) {
            $value = (float) str_ireplace('Cr', '', $normalized);
            return $value * 10000000;
        }

        if (stripos($normalized, 'L') !== false) {
            $value = (float) str_ireplace('L', '', $normalized);
            return $value * 100000;
        }

        return (float) $normalized;
    }

    /**
     * Parse price range and return min/max values.
     *
     * @return array{min: float, max: float}
     */
    private function parsePriceRange(string $price): array
    {
        $parts = preg_split('/[-–]/', $price);
        if (!$parts || count($parts) === 1) {
            $single = $this->parsePrice($price);
            return ['min' => $single, 'max' => $single];
        }

        $min = $this->parsePrice($parts[0]);
        $max = $this->parsePrice($parts[1]);

        if ($min > $max && $max > 0) {
            [$min, $max] = [$max, $min];
        }

        return ['min' => $min, 'max' => $max];
    }

    /**
     * Parse power range and return min/max values.
     *
     * @return array{min: float, max: float}
     */
    private function parsePowerRange(string $power): array
    {
        $normalized = str_replace(['bhp', 'BHP', 'hp', 'HP'], '', $power);
        $parts = preg_split('/[-–]/', $normalized);
        if (!$parts || count($parts) === 1) {
            $single = (float) trim($parts[0]);
            return ['min' => $single, 'max' => $single];
        }

        $min = (float) trim($parts[0]);
        $max = (float) trim($parts[1]);

        if ($min > $max && $max > 0) {
            [$min, $max] = [$max, $min];
        }

        return ['min' => $min, 'max' => $max];
    }



    /**
     * @param mixed $value
     * @return array<int, string>
     */
    private function normalizeArray(mixed $value): array
    {
        if (is_string($value)) {
            $value = strpos($value, ',') !== false ? explode(',', $value) : [$value];
        }
        if (!is_array($value)) {
            return [];
        }

        $items = [];
        foreach ($value as $item) {
            $clean = strtolower(trim((string) $item));
            if ($clean !== '') {
                $items[] = $clean;
            }
        }
        return $items;
    }

    /**
     * Build a deterministic variant ID for consistent lookups.
     *
     * @param array<string, mixed> $model
     * @param array<string, mixed> $variant
     */
    private function buildVariantId(array $model, array $variant): int
    {
        $base = strtolower(
            trim((string) ($model['make'] ?? '')) . '|' .
            trim((string) ($model['model'] ?? '')) . '|' .
            trim((string) ($variant['name'] ?? ''))
        );

        return (int) sprintf('%u', crc32($base));
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantByKey(string $variantKey): ?array
    {
        $this->bootstrap();

        foreach ($this->dataset as $model) {
            foreach ($model['variants'] as $variant) {
                $id = $this->buildVariantId($model, $variant);
                if ((string) $id === $variantKey) {
                    return array_merge($variant, [
                        'id' => $id,
                        'brand' => $model['make'] ?? '',
                        'model' => $model['model'] ?? '',
                        'segment' => $model['segment'] ?? '',
                    ]);
                }
            }
        }

        return null;
    }

    /**
     * @return array<string, mixed>
     */
    public function getSpecsForVariant(string $variantKey): array
    {
        $variant = $this->getVariantByKey($variantKey);
        if ($variant === null) {
            return [];
        }

        return $this->normalizeSpecs($variant);
    }

    /**
     * Normalize spec data to standardized keys and types.
     *
     * @param array<string, mixed> $variant
     * @return array<string, mixed>
     */
    private function normalizeSpecs(array $variant): array
    {
        return [
            'fuel_type' => $this->cleanString($variant['fuel_type'] ?? ''),
            'transmission' => $this->cleanString($variant['transmission'] ?? ''),
            'engine' => $this->cleanString($variant['engine_size'] ?? ''),
            'power_bhp' => $this->safeFloatToString($variant['power_min'] ?? $variant['horsepower'] ?? ''),
            'torque_nm' => $this->cleanString($variant['torque_nm'] ?? ''),
            'mileage_kmpl' => $this->safeFloatToString($variant['mileage_city_kmpl'] ?? ''),
            'range_km' => $this->safeFloatToString($variant['range_km'] ?? ''),
            'seating_capacity' => $this->cleanString($variant['seating_capacity'] ?? ''),
            'fuel_tank_capacity_ltr' => $this->cleanString($variant['fuel_tank_capacity_ltr'] ?? ''),
            'ground_clearance_mm' => $this->cleanString($variant['ground_clearance_mm'] ?? ''),
            'boot_space_ltr' => $this->cleanString($variant['boot_space_ltr'] ?? ''),
        ];
    }

    /**
     * Safely convert float to string, returning empty string for invalid values.
     */
    private function safeFloatToString(mixed $value): string
    {
        if (is_numeric($value)) {
            $float = (float) $value;
            return $float > 0 ? (string) $float : '';
        }
        return $this->cleanString($value);
    }
}
