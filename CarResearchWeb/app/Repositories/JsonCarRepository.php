<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Support\Logger;

/**
 * JSON-backed repository with in-memory caching, validation, and normalization.
 */
class JsonCarRepository
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

    public function __construct(string $dataDir)
    {
        $this->dataDir = $dataDir;
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
        if (!isset($this->modelsByMake[$key])) {
            return [];
        }

        return $this->modelsByMake[$key];
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getModelByName(string $modelName): ?array
    {
        $this->bootstrap();
        $key = strtolower(trim($modelName));

        foreach ($this->dataset as $model) {
            if (strtolower($model['model']) === $key) {
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
            if (strtolower($model['model']) === $key) {
                return $model['variants'];
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
            $modelMake = strtolower($model['make']);
            $modelName = strtolower($model['model']);
            $modelSegment = strtolower($model['segment'] ?? '');

            foreach ($model['variants'] as $variant) {
                $variantName = strtolower($variant['name'] ?? '');
                $variantFuel = strtolower($variant['fuel_type'] ?? '');
                $variantTransmission = strtolower($variant['transmission'] ?? '');
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
                        'id' => count($results) + 1,
                        'brand' => $model['make'],
                        'model' => $model['model'],
                        'variant' => $variant['name'],
                        'segment' => $model['segment'],
                        'fuel_type' => $variant['fuel_type'],
                        'transmission' => $variant['transmission'],
                        'price' => $variant['price_raw'],
                        'price_numeric' => $variantPrice,
                        'engine_size' => $variant['engine_size'] ?? '',
                        'horsepower' => $variant['horsepower'] ?? '',
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
        $path = rtrim($this->dataDir, '/\\') . DIRECTORY_SEPARATOR . $filename;
        if (!is_file($path) || !is_readable($path)) {
            Logger::error('JSON file missing or unreadable', ['file' => $path]);
            return [];
        }

        $content = file_get_contents($path);
        if ($content === false) {
            Logger::error('Failed to read JSON file', ['file' => $path]);
            return [];
        }

        try {
            $decoded = json_decode($content, true, 512, JSON_THROW_ON_ERROR);
        } catch (\JsonException $e) {
            Logger::error('Invalid JSON content', ['file' => $path, 'error' => $e->getMessage()]);
            return [];
        }

        if (!is_array($decoded)) {
            Logger::error('JSON root must be an array', ['file' => $path]);
            return [];
        }

        return $decoded;
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>|null
     */
    private function normalizeCarsetRow(int $index, array $row): ?array
    {
        $make = $this->cleanString($row['make'] ?? '');
        $model = $this->cleanString($row['model'] ?? '');
        $segment = $this->cleanString($row['segment'] ?? '');
        $launchYear = isset($row['launch_year']) ? (int) $row['launch_year'] : null;
        $variantsRaw = $row['variants'] ?? [];

        if ($make === '' || $model === '' || !is_array($variantsRaw) || $variantsRaw === []) {
            Logger::error('Skipping malformed primary row', ['index' => $index]);
            return null;
        }

        $variants = [];
        foreach ($variantsRaw as $variantIndex => $variant) {
            $name = $this->cleanString($variant['name'] ?? '');
            $priceRaw = $this->cleanString($variant['price'] ?? '');
            $fuel = $this->cleanString($variant['fuel_type'] ?? '');
            if ($name === '' || $fuel === '') {
                Logger::error('Skipping malformed variant', ['row' => $index, 'variant' => $variantIndex]);
                continue;
            }

            $priceNumeric = $this->parsePrice($priceRaw);
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
                'horsepower' => $this->cleanString($variant['horsepower'] ?? ''),
            ];
        }

        if ($variants === []) {
            Logger::error('No valid variants after normalization', ['row' => $index]);
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
            $makeKey = strtolower($model['make']);
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
}
