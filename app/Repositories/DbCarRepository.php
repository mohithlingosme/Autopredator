<?php
declare(strict_types=1);

namespace App\Repositories;

use PDO;

/**
 * Database-backed repository for car data.
 */
class DbCarRepository implements CarRepositoryInterface
{
    private PDO $db;

    public function __construct(PDO $pdo)
    {
        $this->db = $pdo;
    }

    public function getBrands(): array
    {
        $sql = <<<SQL
            SELECT m.id,
                   m.name,
                   m.country,
                   COUNT(DISTINCT mo.id)   AS model_count,
                   MIN(v.ex_showroom_price) AS min_price,
                   MAX(v.ex_showroom_price) AS max_price
            FROM manufacturers m
            LEFT JOIN models mo ON mo.manufacturer_id = m.id
            LEFT JOIN variants v ON v.model_id = mo.id
            GROUP BY m.id, m.name, m.country
            ORDER BY m.name
        SQL;

        $rows = $this->selectAll($sql);

        return array_map(function (array $row): array {
            return [
                'id' => (int) $row['id'],
                'name' => (string) $row['name'],
                'slug' => $this->slugify((string) $row['name']),
                'country' => $row['country'] ?? null,
                'model_count' => (int) ($row['model_count'] ?? 0),
                'min_price' => $row['min_price'] !== null ? (float) $row['min_price'] : null,
                'max_price' => $row['max_price'] !== null ? (float) $row['max_price'] : null,
            ];
        }, $rows);
    }

    public function getModelsByMake(string $make): array
    {
        $make = trim($make);
        if ($make === '') {
            return [];
        }

        $manufacturer = $this->selectOne(
            'SELECT id, name, country FROM manufacturers WHERE LOWER(name) = LOWER(?) LIMIT 1',
            [$make]
        );

        if ($manufacturer === null) {
            return [];
        }

        $models = $this->selectAll(
            'SELECT m.id, m.name, m.launch_year, m.family_id, COALESCE(mf.segment, mf.body_type) AS segment
             FROM models m
             LEFT JOIN model_families mf ON mf.id = m.family_id
             WHERE m.manufacturer_id = ?
             ORDER BY m.name',
            [$manufacturer['id']]
        );

        if ($models === []) {
            return [];
        }

        $variantsByModel = $this->loadVariantsForModels(array_column($models, 'id'), $manufacturer['name']);

        $result = [];
        foreach ($models as $modelRow) {
            $modelId = (int) $modelRow['id'];
            $variants = $variantsByModel[$modelId] ?? [];

            $fuelTypes = array_values(array_unique(array_map(
                static fn($row) => (string) $row['fuel_type'],
                $variants
            )));

            $prices = array_column($variants, 'price_numeric');
            $segment = $modelRow['segment'] ?? 'Car';

            $result[] = [
                'id' => $modelId,
                'make' => (string) $manufacturer['name'],
                'model' => (string) $modelRow['name'],
                'segment' => $segment !== '' ? $segment : 'Car',
                'launch_year' => isset($modelRow['launch_year']) ? (int) $modelRow['launch_year'] : null,
                'variants' => $variants,
                'variant_count' => count($variants),
                'fuel_types' => $fuelTypes,
                'price_range' => [
                    'min' => $prices ? min($prices) : 0,
                    'max' => $prices ? max($prices) : 0,
                ],
                'slug' => $this->slugify((string) ($manufacturer['name'] . '-' . $modelRow['name'])),
            ];
        }

        return $result;
    }

    public function getModelByName(string $modelName): ?array
    {
        $modelName = trim($modelName);
        if ($modelName === '') {
            return null;
        }

        $row = $this->selectOne(
            'SELECT m.id,
                    m.name,
                    m.launch_year,
                    m.family_id,
                    m.manufacturer_id,
                    ma.name AS make,
                    COALESCE(mf.segment, mf.body_type) AS segment
             FROM models m
             JOIN manufacturers ma ON ma.id = m.manufacturer_id
             LEFT JOIN model_families mf ON mf.id = m.family_id
             WHERE LOWER(m.name) = LOWER(?)
             LIMIT 1',
            [$modelName]
        );

        if ($row === null) {
            return null;
        }

        $variantsByModel = $this->loadVariantsForModels([(int) $row['id']], (string) $row['make']);
        $variants = $variantsByModel[(int) $row['id']] ?? [];
        $prices = array_column($variants, 'price_numeric');
        $segment = $row['segment'] ?? 'Car';

        return [
            'id' => (int) $row['id'],
            'make' => (string) $row['make'],
            'model' => (string) $row['name'],
            'segment' => $segment !== '' ? $segment : 'Car',
            'launch_year' => isset($row['launch_year']) ? (int) $row['launch_year'] : null,
            'variants' => $variants,
            'variant_count' => count($variants),
            'fuel_types' => array_values(array_unique(array_map(
                static fn($v) => (string) $v['fuel_type'],
                $variants
            ))),
            'price_range' => [
                'min' => $prices ? min($prices) : 0,
                'max' => $prices ? max($prices) : 0,
            ],
            'slug' => $this->slugify((string) ($row['make'] . '-' . $row['name'])),
        ];
    }

    public function getVariantsByModel(string $modelName): array
    {
        $model = $this->getModelByName($modelName);
        return $model['variants'] ?? [];
    }

    public function search(array $filters): array
    {
        $conditions = [];
        $params = [];

        $brand = strtolower(trim((string) ($filters['brand'] ?? '')));
        $model = strtolower(trim((string) ($filters['model'] ?? '')));
        $fuelTypes = $this->normalizeArray($filters['fuel_type'] ?? []);
        $transmissions = $this->normalizeArray($filters['transmission'] ?? []);
        $bodyTypes = $this->normalizeArray($filters['body_type'] ?? []);
        $minPrice = isset($filters['min_price']) && $filters['min_price'] !== '' ? (float) $filters['min_price'] : null;
        $maxPrice = isset($filters['max_price']) && $filters['max_price'] !== '' ? (float) $filters['max_price'] : null;
        $search = strtolower(trim((string) ($filters['search'] ?? $filters['search_text'] ?? '')));

        if ($brand !== '') {
            $conditions[] = 'LOWER(ma.name) = ?';
            $params[] = $brand;
        }
        if ($model !== '') {
            $conditions[] = 'LOWER(m.name) = ?';
            $params[] = $model;
        }
        if ($fuelTypes) {
            $placeholders = implode(',', array_fill(0, count($fuelTypes), '?'));
            $conditions[] = 'LOWER(v.fuel_type) IN (' . $placeholders . ')';
            foreach ($fuelTypes as $f) {
                $params[] = strtolower($f);
            }
        }
        if ($transmissions) {
            $placeholders = implode(',', array_fill(0, count($transmissions), '?'));
            $conditions[] = 'LOWER(v.transmission) IN (' . $placeholders . ')';
            foreach ($transmissions as $t) {
                $params[] = strtolower($t);
            }
        }
        if ($bodyTypes) {
            $placeholders = implode(',', array_fill(0, count($bodyTypes), '?'));
            $conditions[] = 'LOWER(COALESCE(mf.segment, mf.body_type)) IN (' . $placeholders . ')';
            foreach ($bodyTypes as $b) {
                $params[] = strtolower($b);
            }
        }
        if ($minPrice !== null) {
            $conditions[] = 'v.ex_showroom_price >= ?';
            $params[] = $minPrice;
        }
        if ($maxPrice !== null) {
            $conditions[] = 'v.ex_showroom_price <= ?';
            $params[] = $maxPrice;
        }
        if ($search !== '') {
            $conditions[] = '(LOWER(ma.name) LIKE ? OR LOWER(m.name) LIKE ? OR LOWER(v.variant_name) LIKE ?)';
            $like = '%' . $search . '%';
            $params[] = $like;
            $params[] = $like;
            $params[] = $like;
        }

        $where = $conditions ? ('WHERE ' . implode(' AND ', $conditions)) : '';

        $sortBy = $filters['sort_by'] ?? 'price_asc';
        $orderBy = match ($sortBy) {
            'price_desc' => 'v.ex_showroom_price DESC',
            'name_asc' => 'm.name ASC',
            'name_desc' => 'm.name DESC',
            default => 'v.ex_showroom_price ASC',
        };

        $limit = isset($filters['limit']) ? max(1, (int) $filters['limit']) : 12;
        $offset = isset($filters['offset']) ? max(0, (int) $filters['offset']) : 0;

        $sql = <<<SQL
            SELECT v.id,
                   ma.name AS brand,
                   m.name AS model,
                   v.variant_name AS variant,
                   COALESCE(mf.segment, mf.body_type) AS segment,
                   v.fuel_type,
                   v.transmission,
                   v.ex_showroom_price AS price_numeric,
                   v.power,
                   v.mileage
            FROM variants v
            JOIN models m ON v.model_id = m.id
            JOIN manufacturers ma ON m.manufacturer_id = ma.id
            LEFT JOIN model_families mf ON m.family_id = mf.id
            {$where}
            ORDER BY {$orderBy}
            LIMIT ? OFFSET ?
        SQL;

        $params[] = $limit;
        $params[] = $offset;

        $rows = $this->selectAll($sql, $params);

        return array_map([$this, 'convertVariantRow'], $rows);
    }

    public function getVariantById(int $id): ?array
    {
        $row = $this->selectOne(
            'SELECT v.id,
                    v.variant_name,
                    v.fuel_type,
                    v.transmission,
                    v.ex_showroom_price,
                    v.power,
                    v.mileage,
                    m.id AS model_id,
                    m.name AS model_name,
                    ma.id AS manufacturer_id,
                    ma.name AS manufacturer_name,
                    COALESCE(mf.segment, mf.body_type) AS segment,
                    specs.engine_displacement_cc,
                    specs.max_power_bhp,
                    specs.max_torque_nm,
                    specs.mileage_city_kmpl,
                    specs.mileage_highway_kmpl,
                    specs.seating_capacity,
                    specs.fuel_tank_capacity_ltr,
                    specs.ground_clearance_mm,
                    specs.boot_space_ltr
             FROM variants v
             JOIN models m ON v.model_id = m.id
             JOIN manufacturers ma ON m.manufacturer_id = ma.id
             LEFT JOIN model_families mf ON m.family_id = mf.id
             LEFT JOIN vehicle_specs specs ON specs.variant_id = v.id
             WHERE v.id = ?
             LIMIT 1',
            [$id]
        );

        if ($row === null) {
            return null;
        }

        return [
            'id' => (int) $row['id'],
            'variant_name' => (string) $row['variant_name'],
            'fuel_type' => $row['fuel_type'] ?? '',
            'transmission' => $row['transmission'] ?? '',
            'ex_showroom_price' => $row['ex_showroom_price'] !== null ? (float) $row['ex_showroom_price'] : null,
            'model_name' => $row['model_name'] ?? '',
            'manufacturer_name' => $row['manufacturer_name'] ?? '',
            'manufacturer_id' => isset($row['manufacturer_id']) ? (int) $row['manufacturer_id'] : null,
            'model_id' => isset($row['model_id']) ? (int) $row['model_id'] : null,
            'body_type' => $row['segment'] ?? 'Car',
            'engine_displacement_cc' => $row['engine_displacement_cc'] ?? null,
            'max_power_bhp' => $row['max_power_bhp'] ?? $row['power'] ?? null,
            'max_torque_nm' => $row['max_torque_nm'] ?? null,
            'mileage_city_kmpl' => $row['mileage_city_kmpl'] ?? $row['mileage'] ?? null,
            'mileage_highway_kmpl' => $row['mileage_highway_kmpl'] ?? null,
            'seating_capacity' => $row['seating_capacity'] ?? null,
            'fuel_tank_capacity_ltr' => $row['fuel_tank_capacity_ltr'] ?? null,
            'ground_clearance_mm' => $row['ground_clearance_mm'] ?? null,
            'boot_space_ltr' => $row['boot_space_ltr'] ?? null,
        ];
    }

    /**
     * @param array<int, int|string> $ids
     * @return array<int, array<int, array<string, mixed>>>
     */
    private function loadVariantsForModels(array $ids, string $brand): array
    {
        $ids = array_values(array_filter(array_map('intval', $ids)));
        if ($ids === []) {
            return [];
        }

        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $sql = <<<SQL
            SELECT v.id,
                   v.model_id,
                   v.variant_name,
                   v.fuel_type,
                   v.transmission,
                   v.ex_showroom_price,
                   v.power,
                   v.mileage,
                   COALESCE(mf.segment, mf.body_type) AS segment,
                   m.name AS model
            FROM variants v
            JOIN models m ON v.model_id = m.id
            LEFT JOIN model_families mf ON m.family_id = mf.id
            WHERE v.model_id IN ({$placeholders})
            ORDER BY v.ex_showroom_price ASC, v.variant_name ASC
        SQL;

        $rows = $this->selectAll($sql, $ids);

        $grouped = [];
        foreach ($rows as $row) {
            $grouped[(int) $row['model_id']][] = $this->convertVariantRow($row + ['brand' => $brand]);
        }

        return $grouped;
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>
     */
    private function convertVariantRow(array $row): array
    {
        $price = $row['price_numeric'] ?? $row['ex_showroom_price'] ?? 0;

        return [
            'id' => (int) $row['id'],
            'brand' => $row['brand'] ?? '',
            'model' => $row['model'] ?? '',
            'variant' => $row['variant'] ?? $row['variant_name'] ?? '',
            'segment' => $row['segment'] ?? 'Car',
            'fuel_type' => $row['fuel_type'] ?? '',
            'transmission' => $row['transmission'] ?? '',
            'price_numeric' => $price !== null ? (float) $price : 0,
            'price' => $price,
            'engine_size' => '',
            'horsepower' => $row['power'] ?? null,
            'mileage' => $row['mileage'] ?? null,
        ];
    }

    private function slugify(string $text): string
    {
        $text = strtolower(trim($text));
        $text = preg_replace('/[^a-z0-9]+/', '-', $text) ?? '';
        $text = trim($text, '-');

        return $text !== '' ? $text : 'n-a';
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
     * @param array<int, mixed> $params
     * @return array<int, array<string, mixed>>
     */
    private function selectAll(string $sql, array $params = []): array
    {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        /** @var array<int, array<string, mixed>> $rows */
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        return $rows ?: [];
    }

    /**
     * @param array<int, mixed> $params
     * @return array<string, mixed>|null
     */
    private function selectOne(string $sql, array $params = []): ?array
    {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        return $row === false ? null : $row;
    }
}
