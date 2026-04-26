<?php
declare(strict_types=1);

/**
 * Autocomplete API Endpoint
 * Returns JSON suggestions for brand/model search
 */

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/bootstrap.php';

header('Content-Type: application/json; charset=utf-8');

$query = trim($_GET['q'] ?? '');

if (strlen($query) < 2) {
    json_response([]);
}

try {
    $output = [];

    // Search manufacturers
    $manufacturers = get_all_manufacturers();
    foreach ($manufacturers as $man) {
        if (stripos($man['name'], $query) !== false) {
            $output[] = [
                'label' => $man['name'],
                'value' => $man['name'],
                'type' => 'manufacturer',
            ];
        }
    }

    // Search model families
    foreach ($manufacturers as $man) {
        $families = get_model_families_by_manufacturer($man['id']);
        foreach ($families as $family) {
            $label = $man['name'] . ' ' . $family['nameplate'];
            if (stripos($family['nameplate'], $query) !== false || stripos($man['name'], $query) !== false) {
                $output[] = [
                    'label' => $label,
                    'value' => $label,
                    'type' => 'model',
                ];
            }
        }
    }

    // Limit to 10
    $output = array_slice($output, 0, 10);

    json_response($output);

} catch (Exception $e) {
    json_response(['error' => 'Search failed'], 500);
}

function json_response(array $data, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}
