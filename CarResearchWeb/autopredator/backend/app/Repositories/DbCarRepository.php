<?php
declare(strict_types=1);

namespace App\Repositories;

use PDO;

/**
 * Database-backed repository that prefers slug-based lookups and the latest ex-showroom view when available.
 */
class DbCarRepository implements CarRepositoryInterface
{
    private PDO $db;
    private bool $hasLatestPriceView;
    private bool $hasPriceHistory;
    private ?string $priceColumn;

    /** @var array<string, bool> */
    private array $columnCache = [];

    public function __construct(?PDO $db = null)
    {
        $this->db = $db ?? \get_db();
        $this->hasLatestPriceView = $this->objectExists('v_variant_latest_exshowroom', true);
        $this->hasPriceHistory = $this->objectExists('variant_price_history', false);
        $this->priceColumn = $this->detectPriceColumn();
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getBrands(): array
    {
        $stmt = $this->db->query('SELECT id, name, slug, country, logo_url FROM brands ORDER BY name');
        return $stmt !== false ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByBrandSlug(string $brandSlug): array
    {
        $brand = $this->findBrandByNameOrSlug($brandSlug);
        if ($brand === null) {
            return [];
        }

        $select = 'm.id, m.name, m.slug';
        $optional = $this->optionalColumns('models', 'm', ['segment', 'body_type', 'launch_year']);
        if ($optional !== '') {
            $select .= ', ' . $optional;
        }

        $stmt = $this->db->prepare("SELECT {$select} FROM models m WHERE m.brand_id = :brandId ORDER BY m.name");
        $stmt->execute(['brandId' => $brand['id']]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByMake(string $make): array
    {
        $brand = $this->findBrandByNameOrSlug($make);
        if ($brand === null) {
            return [];
        }

        $select = 'm.id, m.name, m.slug';
        $optional = $this->optionalColumns('models', 'm', ['segment', 'body_type', 'launch_year']);
        if ($optional !== '') {
            $select .= ', ' . $optional;
        }

        $stmt = $this->db->prepare("SELECT {$select} FROM models m WHERE m.brand_id = :brandId ORDER BY m.name");
        $stmt->execute(['brandId' => $brand['id']]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getModelByName(string $modelName): ?array
    {
        $stmt = $this->db->prepare('SELECT id, name, slug, brand_id FROM models WHERE name = :name OR slug = :slug LIMIT 1');
        $stmt->execute([
            'name' => $modelName,
            'slug' => $this->slugify($modelName),
        ]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        return $row !== false ? $row : null;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModelSlug(string $modelSlug): array
    {
        $stmt = $this->db->prepare('SELECT id, name FROM models WHERE slug = :slug OR name = :name LIMIT 1');
        $stmt->execute([
            'slug' => $this->slugify($modelSlug),
            'name' => $modelSlug,
        ]);
        $model = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($model === false) {
            return [];
        }

        [$priceJoin, $priceExpr] = $this->priceJoinSql();
        $select = 'v.id, v.name, v.slug, v.fuel_type, v.transmission_type, v.body_type';
        if ($priceExpr !== '') {
            $select .= ', ' . $priceExpr . ' AS price_numeric';
        }

        $stmt = $this->db->prepare("
            SELECT {$select}
            FROM variants v
            {$priceJoin}
            WHERE v.model_id = :modelId
            ORDER BY v.name
        ");
        $stmt->execute(['modelId' => $model['id']]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($row) => $this->normalizeVariantRow($row), $rows);
    }

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function searchVariants(array $filters): array
    {
        $normalized = $filters;

        if (!empty($filters['brand_slug'])) {
            $normalized['brand'] = $filters['brand_slug'];
        }
        if (!empty($filters['model_slug'])) {
            $normalized['model'] = $filters['model_slug'];
        }

        if (isset($filters['fuel'])) {
            $normalized['fuel_type'] = $filters['fuel'];
        }
        if (isset($filters['transmission_type'])) {
            $normalized['transmission'] = $filters['transmission_type'];
        } elseif (isset($filters['transmission'])) {
            $normalized['transmission'] = $filters['transmission'];
        }

        if (isset($filters['minPrice'])) {
            $normalized['price_min'] = (float) $filters['minPrice'];
        } elseif (isset($filters['min_price'])) {
            $normalized['price_min'] = (float) $filters['min_price'];
        }
        if (isset($filters['maxPrice'])) {
            $normalized['price_max'] = (float) $filters['maxPrice'];
        } elseif (isset($filters['max_price'])) {
            $normalized['price_max'] = (float) $filters['max_price'];
        }

        if (isset($filters['query'])) {
            $normalized['variant'] = $filters['query'];
        }

        return $this->search($normalized);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModel(string $modelName): array
    {
        $model = $this->getModelByName($modelName);
        if ($model === null) {
            return [];
        }

        [$priceJoin, $priceExpr] = $this->priceJoinSql();
        $select = 'v.id, v.name, v.slug, v.fuel_type, v.transmission_type, v.body_type';
        if ($priceExpr !== '') {
            $select .= ', ' . $priceExpr . ' AS price_numeric';
        }

        $stmt = $this->db->prepare("
            SELECT {$select}
            FROM variants v
            {$priceJoin}
            WHERE v.model_id = :modelId
            ORDER BY v.name
        ");
        $stmt->execute(['modelId' => $model['id']]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($row) => $this->normalizeVariantRow($row), $rows);
    }

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function search(array $filters): array
    {
        [$priceJoin, $priceExpr] = $this->priceJoinSql();
        $select = implode(', ', array_filter([
            'v.id',
            'v.name AS variant',
            'v.slug',
            'm.name AS model',
            'b.name AS brand',
            'v.fuel_type',
            'v.transmission_type AS transmission',
            'v.body_type',
            $priceExpr !== '' ? $priceExpr . ' AS price_numeric' : 'NULL AS price_numeric',
        ]));

        $sql = "
            SELECT {$select}
            FROM variants v
            JOIN models m ON v.model_id = m.id
            JOIN brands b ON m.brand_id = b.id
            {$priceJoin}
            WHERE 1=1
        ";

        $params = [];
        if (!empty($filters['brand'])) {
            $sql .= ' AND (b.slug = :brandSlug OR b.name = :brandName)';
            $params['brandSlug'] = $this->slugify((string) $filters['brand']);
            $params['brandName'] = $filters['brand'];
        }
        if (!empty($filters['model'])) {
            $sql .= ' AND (m.slug = :modelSlug OR m.name = :modelName)';
            $params['modelSlug'] = $this->slugify((string) $filters['model']);
            $params['modelName'] = $filters['model'];
        }
        if (!empty($filters['variant'])) {
            $sql .= ' AND v.name LIKE :variantName';
            $params['variantName'] = '%' . $filters['variant'] . '%';
        }
        if (!empty($filters['fuel_type'])) {
            $fuelList = is_array($filters['fuel_type']) ? $filters['fuel_type'] : [$filters['fuel_type']];
            $placeholders = [];
            foreach ($fuelList as $idx => $fuel) {
                $key = 'fuel' . $idx;
                $placeholders[] = ':' . $key;
                $params[$key] = $fuel;
            }
            $sql .= ' AND v.fuel_type IN (' . implode(',', $placeholders) . ')';
        }
        if (!empty($filters['transmission'])) {
            $sql .= ' AND v.transmission_type = :transmission';
            $params['transmission'] = $filters['transmission'];
        }
        if (!empty($filters['body_type'])) {
            $sql .= ' AND v.body_type = :bodyType';
            $params['bodyType'] = $filters['body_type'];
        } elseif (!empty($filters['segment'])) {
            $sql .= ' AND m.segment = :segment';
            $params['segment'] = $filters['segment'];
        }
        if (isset($filters['price_min']) && $priceExpr !== '') {
            $sql .= ' AND ((' . $priceExpr . ') IS NULL OR (' . $priceExpr . ') >= :priceMin)';
            $params['priceMin'] = (float) $filters['price_min'];
        }
        if (isset($filters['price_max']) && $priceExpr !== '') {
            $sql .= ' AND ((' . $priceExpr . ') IS NULL OR (' . $priceExpr . ') <= :priceMax)';
            $params['priceMax'] = (float) $filters['price_max'];
        }

        $sortBy = $filters['sort_by'] ?? 'price_asc';
        $order = match ($sortBy) {
            'price_desc' => 'price_numeric DESC',
            'name_desc' => 'model DESC',
            'name_asc' => 'model ASC',
            default => 'price_numeric ASC',
        };
        $sql .= " ORDER BY {$order}";

        $limit = isset($filters['limit']) ? max(1, (int) $filters['limit']) : 20;
        $offset = isset($filters['offset']) ? max(0, (int) $filters['offset']) : 0;
        $sql .= ' LIMIT :limit OFFSET :offset';
        $params['limit'] = $limit;
        $params['offset'] = $offset;

        $stmt = $this->db->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        return array_map(fn($row) => $this->normalizeVariantRow($row), $rows);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantById(int $id): ?array
    {
        return $this->fetchVariant('v.id = :id', ['id' => $id]);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantBySlug(string $slug): ?array
    {
        return $this->fetchVariant('v.slug = :slug', ['slug' => $slug]);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantByKey(string $variantKey): ?array
    {
        if (is_numeric($variantKey)) {
            return $this->getVariantById((int) $variantKey);
        }

        return $this->getVariantBySlug($variantKey) ?? $this->fetchVariant('v.name = :name', ['name' => $variantKey]);
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

        if (!$this->objectExists('vehicle_specs')) {
            return [];
        }

        $stmt = $this->db->prepare('SELECT * FROM vehicle_specs WHERE variant_id = :id LIMIT 1');
        $stmt->execute(['id' => $variant['id']]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        return $row !== false ? $row : [];
    }

    /**
     * @param array<string, mixed> $params
     * @return array<string, mixed>|null
     */
    private function fetchVariant(string $whereClause, array $params): ?array
    {
        [$priceJoin, $priceExpr] = $this->priceJoinSql();
        $select = implode(', ', array_filter([
            'v.id',
            'v.name AS variant',
            'v.slug',
            'v.fuel_type',
            'v.transmission_type AS transmission',
            'v.body_type',
            'm.name AS model',
            'b.name AS brand',
            $priceExpr !== '' ? $priceExpr . ' AS price_numeric' : 'NULL AS price_numeric',
        ]));

        $sql = "
            SELECT {$select}
            FROM variants v
            JOIN models m ON v.model_id = m.id
            JOIN brands b ON m.brand_id = b.id
            {$priceJoin}
            WHERE {$whereClause}
            LIMIT 1
        ";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row === false) {
            return null;
        }

        $variant = $this->normalizeVariantRow($row);
        $variant['images'] = $this->getImagesForVariant((int) $variant['id']);

        return $variant;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function getImagesForVariant(int $variantId): array
    {
        if (!$this->objectExists('images')) {
            return [];
        }

        $stmt = $this->db->prepare('SELECT id, image_url, is_thumbnail FROM images WHERE variant_id = :variant ORDER BY is_thumbnail DESC, id ASC');
        $stmt->execute(['variant' => $variantId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $seenThumbnail = false;
        return array_map(function ($row) use (&$seenThumbnail) {
            $isThumb = (int) ($row['is_thumbnail'] ?? 0) === 1 && !$seenThumbnail;
            if ($isThumb) {
                $seenThumbnail = true; // enforce single thumbnail in returned payload
            }
            return [
                'id' => (int) $row['id'],
                'image_url' => $row['image_url'],
                'is_thumbnail' => $isThumb ? 1 : 0,
            ];
        }, $rows);
    }

    /**
     * @return array{0:string,1:string}
     */
    private function priceJoinSql(): array
    {
        if ($this->priceColumn !== null && $this->hasLatestPriceView) {
            $col = $this->priceColumn;
            return [
                'LEFT JOIN v_variant_latest_exshowroom lp ON lp.variant_id = v.id',
                "lp.`{$col}`",
            ];
        }

        if ($this->priceColumn !== null && $this->hasPriceHistory) {
            $col = $this->priceColumn;
            return [
                'LEFT JOIN (
                    SELECT vph.variant_id, vph.`' . $col . '` AS price_numeric
                    FROM variant_price_history vph
                    JOIN (
                        SELECT variant_id, MAX(as_of_date) AS max_date
                        FROM variant_price_history
                        WHERE price_type = \"ex_showroom\"
                        GROUP BY variant_id
                    ) latest ON latest.variant_id = vph.variant_id AND latest.max_date = vph.as_of_date
                    WHERE vph.price_type = \"ex_showroom\"
                ) lp ON lp.variant_id = v.id',
                'lp.price_numeric',
            ];
        }

        return ['', ''];
    }

    private function detectPriceColumn(): ?string
    {
        $candidates = ['price_amount', 'price', 'amount', 'ex_showroom_price'];
        $source = $this->hasLatestPriceView ? 'v_variant_latest_exshowroom' : ($this->hasPriceHistory ? 'variant_price_history' : null);
        if ($source === null) {
            return null;
        }

        foreach ($candidates as $column) {
            if ($this->columnExists($source, $column)) {
                return $column;
            }
        }

        return null;
    }

    private function slugify(string $value): string
    {
        $value = strtolower(trim($value));
        $value = preg_replace('/[^a-z0-9]+/i', '-', $value) ?? '';
        return trim($value, '-');
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>
     */
    private function normalizeVariantRow(array $row): array
    {
        $row['price_numeric'] = isset($row['price_numeric']) ? (float) $row['price_numeric'] : null;
        return $row;
    }

    /**
     * @return array<string, mixed>|null
     */
    private function findBrandByNameOrSlug(string $needle): ?array
    {
        $stmt = $this->db->prepare('SELECT id, name, slug FROM brands WHERE slug = :slug OR name = :name LIMIT 1');
        $stmt->execute([
            'slug' => $this->slugify($needle),
            'name' => $needle,
        ]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        return $row !== false ? $row : null;
    }

    private function objectExists(string $name, bool $view = false): bool
    {
        $tableType = $view ? 'VIEWS' : 'TABLES';
        $stmt = $this->db->prepare(
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.{$tableType} WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :name"
        );
        $stmt->execute(['name' => $name]);
        return (int) $stmt->fetchColumn() > 0;
    }

    private function columnExists(string $table, string $column): bool
    {
        $cacheKey = $table . '.' . $column;
        if (array_key_exists($cacheKey, $this->columnCache)) {
            return $this->columnCache[$cacheKey];
        }

        $stmt = $this->db->prepare(
            'SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :table AND COLUMN_NAME = :column'
        );
        $stmt->execute(['table' => $table, 'column' => $column]);
        $exists = (int) $stmt->fetchColumn() > 0;
        $this->columnCache[$cacheKey] = $exists;

        return $exists;
    }

    private function optionalColumns(string $table, string $alias, array $columns): string
    {
        $parts = [];
        foreach ($columns as $col) {
            if ($this->columnExists($table, $col)) {
                $parts[] = "{$alias}.{$col}";
            } else {
                $parts[] = "NULL AS {$col}";
            }
        }

        return implode(', ', $parts);
    }
}
