<?php
declare(strict_types=1);

/**
 * Normalize an input into an array of strings.
 *
 * Accepts comma-separated string, scalar, or array inputs.
 *
 * @param mixed $value
 * @return array<int, string>
 */
function normalize_array_filter($value): array
{
    if (is_array($value)) {
        $items = $value;
    } elseif (is_string($value)) {
        $items = strpos($value, ',') !== false ? explode(',', $value) : [$value];
    } else {
        return [];
    }

    $clean = [];
    foreach ($items as $item) {
        $trimmed = trim((string) $item);
        if ($trimmed !== '') {
            $clean[] = $trimmed;
        }
    }

    return $clean;
}

/**
 * Build normalized filters array from $_GET.
 *
 * @param array<string, mixed> $input
 * @return array<string, mixed>
 */
function build_search_filters(array $input): array
{
    $filters = [];

    $filters['search_text'] = isset($input['q']) ? trim((string) $input['q']) : '';

    $filters['manufacturer_id'] = isset($input['manufacturer_id']) && is_numeric($input['manufacturer_id'])
        ? (int) $input['manufacturer_id']
        : null;

    $filters['body_type'] = normalize_array_filter($input['body_type'] ?? []);
    $filters['fuel_type'] = normalize_array_filter($input['fuel_type'] ?? []);
    $filters['transmission'] = normalize_array_filter($input['transmission'] ?? []);

    $filters['min_budget'] = isset($input['min_budget']) && $input['min_budget'] !== '' ? (float) $input['min_budget'] : null;
    $filters['max_budget'] = isset($input['max_budget']) && $input['max_budget'] !== '' ? (float) $input['max_budget'] : null;

    $filters['seats'] = isset($input['seats']) && $input['seats'] !== '' ? (int) $input['seats'] : null;

    $page = isset($input['page']) && (int) $input['page'] > 0 ? (int) $input['page'] : 1;
    $limit = 12;
    $offset = ($page - 1) * $limit;

    $filters['limit'] = $limit;
    $filters['offset'] = $offset;
    $filters['page'] = $page;

    $filters['sort_by'] = isset($input['sort_by']) && is_string($input['sort_by']) ? $input['sort_by'] : 'price_asc';

    return $filters;
}
