<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * Get a shared PDO instance (singleton-style with connection pooling).
 */
function get_db(): PDO
{
    static $pdo = null;
    static $lastConnectionTime = 0;
    $reconnectInterval = 300; // 5 minutes

    // Check if we need to reconnect (for long-running processes)
    if ($pdo instanceof PDO && (time() - $lastConnectionTime) > $reconnectInterval) {
        try {
            $pdo->query('SELECT 1'); // Test connection
        } catch (PDOException $e) {
            $pdo = null; // Force reconnection
        }
    }

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $maxRetries = 3;
    $retryDelay = 1; // seconds

    for ($attempt = 1; $attempt <= $maxRetries; $attempt++) {
        try {
            $pdo = new PDO(
                db_dsn(),
                DB_USER,
                DB_PASS,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                    PDO::ATTR_PERSISTENT => true, // Connection pooling
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
                ]
            );

            $lastConnectionTime = time();
            return $pdo;
        } catch (PDOException $e) {
            if ($attempt === $maxRetries) {
                global $APP_ENV;
                $isLocal = ($APP_ENV ?? 'production') === 'local';

                if ($isLocal) {
                    throw new RuntimeException('Database connection failed after ' . $maxRetries . ' attempts: ' . $e->getMessage(), 0, $e);
                }

                throw new RuntimeException('Database connection failed.', 0, $e);
            }

            sleep($retryDelay);
            $retryDelay *= 2; // Exponential backoff
        }
    }

    throw new RuntimeException('Database connection failed.');
}

/**
 * Run a SELECT query and return all rows.
 *
 * @param array<int|string, mixed> $params
 * @return array<int, array<string, mixed>>
 */
function db_select(string $sql, array $params = []): array
{
    try {
        $stmt = get_db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    } catch (PDOException $e) {
        throw new RuntimeException('Database query failed.', 0, $e);
    }
}

/**
 * Run a SELECT query and return a single row or null.
 *
 * @param array<int|string, mixed> $params
 * @return array<string, mixed>|null
 */
function db_select_one(string $sql, array $params = []): ?array
{
    try {
        $stmt = get_db()->prepare($sql);
        $stmt->execute($params);
        $row = $stmt->fetch();

        return $row === false ? null : $row;
    } catch (PDOException $e) {
        throw new RuntimeException('Database query failed.', 0, $e);
    }
}

/**
 * Execute an INSERT/UPDATE/DELETE and return affected rows.
 *
 * @param array<int|string, mixed> $params
 */
function db_execute(string $sql, array $params = []): int
{
    try {
        $stmt = get_db()->prepare($sql);
        $stmt->execute($params);

        return $stmt->rowCount();
    } catch (PDOException $e) {
        throw new RuntimeException('Database query failed.', 0, $e);
    }
}

/**
 * Get the last inserted ID from the shared PDO instance.
 */
function db_last_insert_id(): string
{
    return get_db()->lastInsertId();
}
