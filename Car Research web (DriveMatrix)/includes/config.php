<?php
declare(strict_types=1);

/**
 * Application environment: set to 'local' for development or 'production' for live.
 *
 * You can override via an environment variable APP_ENV if desired.
 */
$APP_ENV = getenv('APP_ENV') !== false ? getenv('APP_ENV') : 'local';

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
