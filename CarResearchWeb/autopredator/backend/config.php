<?php
declare(strict_types=1);

// Application paths
define('BASE_PATH', __DIR__);
define('DATA_DIR', __DIR__ . '/data');

// Environment
define('APP_ENV', getenv('APP_ENV') ?: 'production');
define('USE_JSON', filter_var(getenv('USE_JSON') ?: 'false', FILTER_VALIDATE_BOOLEAN));

// Database credentials (env override friendly)
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_PORT', (int) (getenv('DB_PORT') ?: 3306));
define('DB_NAME', getenv('DB_NAME') ?: 'autopredator_cars');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_CHARSET', 'utf8mb4');

// Graphify auto-generation settings
// Set GRAPHIFY_AUTO_GENERATE=true to rebuild graphify-out/graph.json after data updates
define('GRAPHIFY_AUTO_GENERATE', filter_var(getenv('GRAPHIFY_AUTO_GENERATE') ?: 'false', FILTER_VALIDATE_BOOLEAN));
define('GRAPHIFY_TARGET_PATH', getenv('GRAPHIFY_TARGET_PATH') ?: __DIR__);

function db_dsn(): string
{
    return sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', DB_HOST, DB_PORT, DB_NAME, DB_CHARSET);
}
