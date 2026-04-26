<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/db.php';

if (php_sapi_name() !== 'cli') {
    header('Content-Type: text/plain');
}

try {
    $pdo = get_db();
    $tables = $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);

    echo "Connection OK\n";
    echo "Database: " . DB_NAME . "\n";
    echo "Tables (" . count($tables) . "):\n";
    foreach ($tables as $table) {
        echo "- {$table}\n";
    }
} catch (Throwable $e) {
    http_response_code(500);
    echo "Connection failed: " . $e->getMessage();
}
