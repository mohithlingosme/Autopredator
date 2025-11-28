<?php
declare(strict_types=1);

/**
 * Autocomplete API Endpoint
 * Returns JSON suggestions for brand/model search
 */

require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/db.php';

header('Content-Type: application/json; charset=utf-8');

$query = trim($_GET['q'] ?? '');

if (strlen($query) < 2) {
    json_response([]);
}

try {
    $pdo = get_db();
    
    // Search manufacturers and models
    $sql = '
        SELECT DISTINCT
            "manufacturer" AS type,
            m.name AS value,
            m.id AS id
        FROM manufacturers m
        WHERE m.name LIKE :query
        UNION
        SELECT DISTINCT
            "model" AS type,
            CONCAT(man.name, " ", mf.nameplate) AS value,
            mf.id AS id
        FROM model_families mf
        JOIN manufacturers man ON mf.manufacturer_id = man.id
        WHERE mf.nameplate LIKE :query OR man.name LIKE :query
        LIMIT 10
    ';
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['query' => '%' . $query . '%']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $output = [];
    foreach ($results as $row) {
        $output[] = [
            'label' => $row['value'],
            'value' => $row['value'],
            'type' => $row['type'],
        ];
    }
    
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
