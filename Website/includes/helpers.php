<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

/**
 * Shared helpers for DB access and output safety.
 */

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

    $allowed = ['name', 'email', 'company', 'phone', 'fleet_size', 'message', 'source', 'source_page'];
    $payload = [];
    foreach ($allowed as $field) {
        if (array_key_exists($field, $data)) {
            $payload[$field] = $data[$field];
        }
    }

    if (empty($payload)) {
        return false;
    }

    // Ensure a source_page is present for analytics.
    if (empty($payload['source_page']) && !empty($payload['source'])) {
        $payload['source_page'] = $payload['source'];
        unset($payload['source']);
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

function send_lead_notification(array $lead): bool
{
    $email = $lead['email'] ?? '';
    $name = $lead['name'] ?? '';
    $source = $lead['source_page'] ?? 'website';
    $subject = 'New Autopredator lead';
    $message = "Lead source: {$source}\nName: {$name}\nEmail: {$email}\n";

    if (function_exists('mail')) {
        // Basic mail attempt; failure will fall back to logging.
        @mail('hello@autopredator.com', $subject, $message);
    }

    // Always log for traceability, even if mail is disabled in the environment.
    error_log('Lead capture: ' . $message);
    return true;
}
