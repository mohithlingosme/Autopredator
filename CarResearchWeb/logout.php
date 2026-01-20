<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/auth.php';

auth_logout();

$redirect = $_GET['redirect'] ?? 'index.php';
header('Location: ' . $redirect);
exit;
