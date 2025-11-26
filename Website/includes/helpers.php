<?php
declare(strict_types=1);

/**
 * Shared helpers for DB access and output safety.
 */

function get_db_connection(): ?PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    require __DIR__ . '/config.php';

    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $db_host, $db_name);
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];

    try {
        $pdo = new PDO($dsn, $db_user, $db_pass, $options);
    } catch (PDOException $e) {
        error_log('Database connection failed: ' . $e->getMessage());
        return null;
    }

    return $pdo;
}

function escape_html(?string $str): string
{
    return htmlspecialchars((string) $str, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function get_blog_post_by_slug(string $slug): ?array
{
    $pdo = get_db_connection();
    if (!$pdo) {
        return null;
    }

    $stmt = $pdo->prepare('SELECT * FROM blog_posts WHERE slug = :slug LIMIT 1');
    $stmt->execute(['slug' => $slug]);
    $post = $stmt->fetch();

    return $post ?: null;
}

function create_lead(array $data): bool
{
    $pdo = get_db_connection();
    if (!$pdo) {
        return false;
    }

    $allowed = ['name', 'email', 'company', 'phone', 'fleet_size', 'message', 'source'];
    $payload = [];
    foreach ($allowed as $field) {
        if (array_key_exists($field, $data)) {
            $payload[$field] = $data[$field];
        }
    }

    if (empty($payload)) {
        return false;
    }

    $columns = array_keys($payload);
    $placeholders = array_map(fn($c) => ':' . $c, $columns);
    $sql = 'INSERT INTO leads (' . implode(',', $columns) . ') VALUES (' . implode(',', $placeholders) . ')';

    try {
        $stmt = $pdo->prepare($sql);
        return $stmt->execute($payload);
    } catch (PDOException $e) {
        error_log('Failed to create lead: ' . $e->getMessage());
        return false;
    }
}

function create_newsletter_subscriber(string $email): bool
{
    $pdo = get_db_connection();
    if (!$pdo) {
        return false;
    }

    try {
        $stmt = $pdo->prepare('INSERT INTO newsletter_subscribers (email) VALUES (:email)');
        return $stmt->execute(['email' => $email]);
    } catch (PDOException $e) {
        error_log('Failed to create newsletter subscriber: ' . $e->getMessage());
        return false;
    }
}
