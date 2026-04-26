<?php

declare(strict_types=1);

/**
 * Simple audit logging functions for admin actions.
 * Stores logs in session for now, can be extended to file/DB later.
 */

function audit_log(string $action, array $data = []): void
{
    if (!isset($_SESSION['audit_logs'])) {
        $_SESSION['audit_logs'] = [];
    }

    $log_entry = [
        'timestamp' => date('Y-m-d H:i:s'),
        'action' => $action,
        'data' => $data,
        'user_id' => $_SESSION['user_id'] ?? null,
        'ip' => $_SERVER['REMOTE_ADDR'] ?? null
    ];

    // Keep only last 100 logs in session
    array_unshift($_SESSION['audit_logs'], $log_entry);
    $_SESSION['audit_logs'] = array_slice($_SESSION['audit_logs'], 0, 100);
}

function audit_get_recent_logs(int $limit = 10): array
{
    return array_slice($_SESSION['audit_logs'] ?? [], 0, $limit);
}
