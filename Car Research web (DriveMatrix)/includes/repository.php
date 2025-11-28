<?php
declare(strict_types=1);

require_once __DIR__ . '/db.php';

/**
 * Manufacturers
 */
function get_all_manufacturers(): array
{
    $sql = 'SELECT id, name, country FROM manufacturers ORDER BY name ASC';
    return db_select($sql);
}

function get_manufacturer_by_id(int $id): ?array
{
    $sql = 'SELECT id, name, country FROM manufacturers WHERE id = :id LIMIT 1';
    return db_select_one($sql, ['id' => $id]);
}

/**
 * Families
 */
function get_family_by_id(int $id): ?array
{
    $sql = '
        SELECT mf.*, man.name AS manufacturer_name, man.id AS manufacturer_id
        FROM model_families mf
        JOIN manufacturers man ON man.id = mf.manufacturer_id
        WHERE mf.id = :id
        LIMIT 1
    ';
    return db_select_one($sql, ['id' => $id]);
}

function get_model_families_by_manufacturer(int $manufacturerId): array
{
    $sql = '
        SELECT mf.*,
               (SELECT COUNT(*) FROM models m WHERE m.family_id = mf.id) AS model_count
        FROM model_families mf
        WHERE mf.manufacturer_id = :manufacturer_id
        ORDER BY mf.nameplate ASC
    ';
    return db_select($sql, ['manufacturer_id' => $manufacturerId]);
}

function get_featured_families(int $limit = 6): array
{
    $pdo = get_db();
    $stmt = $pdo->prepare('
        SELECT mf.id, mf.nameplate, mf.body_type, mf.segment, mf.fuel_scope,
               man.id AS manufacturer_id, man.name AS manufacturer_name
        FROM model_families mf
        JOIN manufacturers man ON man.id = mf.manufacturer_id
        ORDER BY mf.id DESC
        LIMIT :limit
    ');
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Models
 */
function get_models_by_family(int $familyId): array
{
    $sql = '
        SELECT m.*,
               man.id AS manufacturer_id,
               man.name AS manufacturer_name,
               mf.nameplate AS family_nameplate,
               mf.body_type,
               mf.segment,
               mf.fuel_scope
        FROM models m
        JOIN manufacturers man ON man.id = m.manufacturer_id
        JOIN model_families mf ON mf.id = m.family_id
        WHERE m.family_id = :family_id
        ORDER BY m.launch_year DESC, m.name ASC
    ';
    return db_select($sql, ['family_id' => $familyId]);
}

function get_model_by_id(int $id): ?array
{
    $sql = '
        SELECT 
            m.*,
            man.id AS manufacturer_id,
            man.name AS manufacturer_name,
            mf.id AS family_id,
            mf.nameplate AS family_nameplate,
            mf.body_type,
            mf.segment,
            mf.fuel_scope
        FROM models m
        JOIN manufacturers man ON man.id = m.manufacturer_id
        JOIN model_families mf ON mf.id = m.family_id
        WHERE m.id = :id
        LIMIT 1
    ';
    return db_select_one($sql, ['id' => $id]);
}

/**
 * Variants
 */
function get_variants_by_model(int $modelId): array
{
    $sql = '
        SELECT v.*,
               m.name AS model_name,
               man.name AS manufacturer_name
        FROM variants v
        JOIN models m ON m.id = v.model_id
        JOIN manufacturers man ON man.id = m.manufacturer_id
        WHERE v.model_id = :model_id
        ORDER BY v.ex_showroom_price ASC, v.variant_name ASC
    ';
    return db_select($sql, ['model_id' => $modelId]);
}

function get_variant_by_id(int $id): ?array
{
    $sql = '
        SELECT 
            v.*,
            m.name AS model_name,
            m.family_id,
            mf.nameplate AS family_nameplate,
            mf.body_type,
            man.id AS manufacturer_id,
            man.name AS manufacturer_name
        FROM variants v
        JOIN models m ON v.model_id = m.id
        JOIN model_families mf ON mf.id = m.family_id
        JOIN manufacturers man ON m.manufacturer_id = man.id
        WHERE v.id = :id
        LIMIT 1
    ';
    return db_select_one($sql, ['id' => $id]);
}

function get_featured_variants(int $limit = 6): array
{
    $pdo = get_db();
    $stmt = $pdo->prepare('
        SELECT v.id, v.variant_name, v.fuel_type, v.transmission, v.ex_showroom_price,
               m.name AS model_name,
               man.name AS manufacturer_name
        FROM variants v
        JOIN models m ON m.id = v.model_id
        JOIN manufacturers man ON man.id = m.manufacturer_id
        ORDER BY v.id DESC
        LIMIT :limit
    ');
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Specs & features
 */
function get_specs_for_variant(int $variantId): ?array
{
    $sql = '
        SELECT *
        FROM vehicle_specs
        WHERE variant_id = :variant_id
        LIMIT 1
    ';
    return db_select_one($sql, ['variant_id' => $variantId]);
}

function get_features_for_variant(int $variantId): array
{
    $sql = '
        SELECT f.id, f.name, f.category
        FROM variant_features vf
        JOIN features f ON vf.feature_id = f.id
        WHERE vf.variant_id = :variant_id
        ORDER BY f.category ASC, f.name ASC
    ';
    return db_select($sql, ['variant_id' => $variantId]);
}

function get_grouped_features_for_variant(int $variantId): array
{
    $features = get_features_for_variant($variantId);
    $grouped = [];

    foreach ($features as $feature) {
        $category = trim((string) ($feature['category'] ?? 'Other'));
        if ($category === '') {
            $category = 'Other';
        }
        if (!isset($grouped[$category])) {
            $grouped[$category] = [];
        }
        $grouped[$category][] = $feature;
    }

    return $grouped;
}

/**
 * Pricing
 */
function get_prices_for_variant(int $variantId, ?int $cityId = null): array
{
    $sql = '
        SELECT ph.*
        FROM price_history ph
        WHERE ph.variant_id = :variant_id
        ORDER BY ph.updated_at DESC
    ';
    return db_select($sql, ['variant_id' => $variantId]);
}

function get_current_price_for_variant(int $variantId, ?int $cityId = null): ?array
{
    $sql = '
        SELECT ph.*
        FROM price_history ph
        WHERE ph.variant_id = :variant_id
        ORDER BY ph.updated_at DESC
        LIMIT 1
    ';
    return db_select_one($sql, ['variant_id' => $variantId]);
}

/**
 * Search
 *
 * @param array<string, mixed> $filters
 * @return array<int, array<string, mixed>>
 */
function search_cars(array $filters): array
{
    $query = build_search_query($filters, false);
    $sql = $query['select'] . $query['from'] . ' WHERE ' . implode(' AND ', $query['where']) . ' ORDER BY ' . $query['order'] . ' LIMIT :limit OFFSET :offset';

    $pdo = get_db();
    $stmt = $pdo->prepare($sql);

    foreach ($query['params'] as $key => $value) {
        $stmt->bindValue(':' . $key, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $stmt->bindValue(':limit', $query['limit'], PDO::PARAM_INT);
    $stmt->bindValue(':offset', $query['offset'], PDO::PARAM_INT);

    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * @param array<string, mixed> $filters
 */
function search_cars_count(array $filters): int
{
    $query = build_search_query($filters, true);
    $sql = $query['select'] . $query['from'] . ' WHERE ' . implode(' AND ', $query['where']);

    $pdo = get_db();
    $stmt = $pdo->prepare($sql);
    foreach ($query['params'] as $key => $value) {
        $stmt->bindValue(':' . $key, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $stmt->execute();

    return (int) $stmt->fetchColumn();
}

/**
 * @param array<string, mixed> $filters
 * @return array<string, mixed>
 */
function build_search_query(array $filters, bool $forCount = false): array
{
    $select = $forCount
        ? 'SELECT COUNT(DISTINCT v.id) AS total'
        : '
        SELECT
            man.id AS manufacturer_id,
            man.name AS manufacturer_name,
            mf.id AS family_id,
            mf.nameplate AS family_nameplate,
            mf.body_type,
            m.id AS model_id,
            m.name AS model_name,
            v.id AS variant_id,
            v.variant_name,
            v.fuel_type,
            v.transmission,
            v.ex_showroom_price
        ';

    $from = '
        FROM variants v
        JOIN models m ON m.id = v.model_id
        JOIN model_families mf ON mf.id = m.family_id
        JOIN manufacturers man ON man.id = m.manufacturer_id
    ';

    $where = ['1=1'];
    $params = [];

    if (!empty($filters['seats'])) {
        $from .= ' LEFT JOIN vehicle_specs vs ON vs.variant_id = v.id';
    }

    if (!empty($filters['manufacturer_id'])) {
        $where[] = 'man.id = :manufacturer_id';
        $params['manufacturer_id'] = (int) $filters['manufacturer_id'];
    }

    if (!empty($filters['family_id'])) {
        $where[] = 'mf.id = :family_id';
        $params['family_id'] = (int) $filters['family_id'];
    }

    if (!empty($filters['body_type'])) {
        [$placeholders, $values] = normalize_multi_filter((array) $filters['body_type'], 'body');
        if ($placeholders) {
            $where[] = 'mf.body_type IN (' . implode(', ', $placeholders) . ')';
            $params += $values;
        }
    }

    if (!empty($filters['fuel_type'])) {
        [$placeholders, $values] = normalize_multi_filter((array) $filters['fuel_type'], 'fuel');
        if ($placeholders) {
            $where[] = 'v.fuel_type IN (' . implode(', ', $placeholders) . ')';
            $params += $values;
        }
    }

    if (!empty($filters['transmission'])) {
        [$placeholders, $values] = normalize_multi_filter((array) $filters['transmission'], 'trans');
        if ($placeholders) {
            $where[] = 'v.transmission IN (' . implode(', ', $placeholders) . ')';
            $params += $values;
        }
    }

    if (isset($filters['min_budget']) && $filters['min_budget'] !== null) {
        $where[] = 'v.ex_showroom_price >= :min_budget';
        $params['min_budget'] = (float) $filters['min_budget'];
    }

    if (isset($filters['max_budget']) && $filters['max_budget'] !== null) {
        $where[] = 'v.ex_showroom_price <= :max_budget';
        $params['max_budget'] = (float) $filters['max_budget'];
    }

    if (!empty($filters['seats'])) {
        $where[] = 'vs.seating_capacity = :seats';
        $params['seats'] = (int) $filters['seats'];
    }

    if (!empty($filters['search_text'])) {
        $where[] = '(man.name LIKE :search_text OR mf.nameplate LIKE :search_text OR m.name LIKE :search_text OR v.variant_name LIKE :search_text)';
        $params['search_text'] = '%' . $filters['search_text'] . '%';
    }

    $order = 'v.ex_showroom_price ASC';
    $sort = $filters['sort_by'] ?? 'price_asc';
    if ($sort === 'price_desc') {
        $order = 'v.ex_showroom_price DESC';
    } elseif ($sort === 'year_desc') {
        $order = 'm.launch_year DESC';
    } elseif ($sort === 'year_asc') {
        $order = 'm.launch_year ASC';
    }

    $limit = isset($filters['limit']) ? max(1, (int) $filters['limit']) : 20;
    $offset = isset($filters['offset']) ? max(0, (int) $filters['offset']) : 0;

    return [
        'select' => $select,
        'from' => $from,
        'where' => $where,
        'params' => $params,
        'order' => $order,
        'limit' => $limit,
        'offset' => $offset,
    ];
}

/**
 * @param array<int, string> $values
 * @return array{0: array<int, string>, 1: array<string, string>}
 */
function normalize_multi_filter(array $values, string $prefix): array
{
    $placeholders = [];
    $params = [];

    $values = array_values(array_filter(array_map('trim', $values), static fn($v) => $v !== ''));

    foreach ($values as $idx => $value) {
        $key = $prefix . '_' . $idx;
        $placeholders[] = ':' . $key;
        $params[$key] = $value;
    }

    return [$placeholders, $params];
}
