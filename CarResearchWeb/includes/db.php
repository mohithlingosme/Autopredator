<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * Get a shared PDO instance (singleton-style).
 */
function get_db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    try {
        $pdo = new PDO(
            db_dsn(),
            DB_USER,
            DB_PASS,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]
        );
    } catch (PDOException $e) {
        global $APP_ENV;
        $isLocal = ($APP_ENV ?? 'production') === 'local';

        if ($isLocal) {
            throw new RuntimeException('Database connection failed: ' . $e->getMessage(), 0, $e);
        }

        throw new RuntimeException('Database connection failed.', 0, $e);
    }

    return $pdo;
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
