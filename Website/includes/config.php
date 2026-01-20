<?php
declare(strict_types=1);

// Database credentials for the PHP site (prefer environment variables, fallback to local defaults).
$db_host = getenv('AP_DB_HOST') ?: 'localhost';
$db_name = getenv('AP_DB_NAME') ?: 'autopredator_site';
$db_user = getenv('AP_DB_USER') ?: 'root';
$db_pass = getenv('AP_DB_PASS') ?: '';

/**
 * Shared PDO connection (singleton per request).
 */
function get_db_connection(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    global $db_host, $db_name, $db_user, $db_pass;
    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $db_host, $db_name);
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];

    $pdo = new PDO($dsn, $db_user, $db_pass, $options);
    return $pdo;
}
