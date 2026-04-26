<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/audit_log.php';

// Check if admin is enabled
if (!ADMIN_ENABLED) {
    http_response_code(404);
    echo 'Admin panel is disabled.';
    exit;
}

// Check if user is logged in
if (!auth_is_logged_in()) {
    header('Location: ' . ADMIN_BASE_URL . '/login.php');
    exit;
}

// Log logout
audit_log('Admin logout');

// Perform logout
auth_logout();

// Redirect to login page
header('Location: ' . ADMIN_BASE_URL . '/login.php');
exit;
?>
