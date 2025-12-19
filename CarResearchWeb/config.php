<?php
declare(strict_types=1);

/**
 * Global application configuration.
 */

// Base paths
define('BASE_PATH', realpath(__DIR__) ?: __DIR__);
define('DATA_DIR', BASE_PATH . DIRECTORY_SEPARATOR . 'data');

// Environment flags
$APP_ENV = getenv('APP_ENV') !== false ? getenv('APP_ENV') : 'local';
define('APP_ENV', $APP_ENV);
define('IS_PRODUCTION', APP_ENV === 'production');

// Error display depending on environment
if (IS_PRODUCTION) {
    ini_set('display_errors', '0');
    ini_set('display_startup_errors', '0');
    error_reporting(E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE);
} else {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

// Toggle JSON vs DB data source
$useJson = getenv('USE_JSON');
define('USE_JSON', $useJson !== false ? (bool) filter_var($useJson, FILTER_VALIDATE_BOOLEAN) : true);

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
