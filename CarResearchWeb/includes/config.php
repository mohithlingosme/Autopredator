<?php
declare(strict_types=1);

/**
 * Application environment: set to 'local' for development or 'production' for live.
 *
 * You can override via an environment variable APP_ENV if desired.
 */
$APP_ENV = getenv('APP_ENV') !== false ? getenv('APP_ENV') : 'local';
$IS_PRODUCTION = $APP_ENV === 'production';

if ($IS_PRODUCTION) {
    ini_set('display_errors', '0');
    ini_set('display_startup_errors', '0');
    error_reporting(E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE);
} else {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

/**
 * Data source mode: set to true to use JSON files as primary data source,
 * false to use MySQL database.
 *
 * You can override via an environment variable USE_JSON if desired.
 */
$USE_JSON = getenv('USE_JSON') !== false ? filter_var(getenv('USE_JSON'), FILTER_VALIDATE_BOOLEAN) : true;
define('USE_JSON', $USE_JSON);

// Database credentials.
const DB_HOST = 'localhost';
const DB_NAME = 'autopredator_unified';
const DB_USER = 'root';
const DB_PASS = '';
const DB_CHARSET = 'utf8mb4';

/**
 * Build the DSN string for PDO.
 */
function db_dsn(): string
{
    return sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET);
}
