<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/auth.php';

auth_session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $variantId = isset($_POST['variant_id']) ? (int) $_POST['variant_id'] : 0;
    $action = $_POST['action'] ?? 'add';

    if (!auth_is_logged_in()) {
        $redirect = 'login.php?redirect=' . urlencode($_SERVER['HTTP_REFERER'] ?? 'index.php');
        header('Location: ' . $redirect);
        exit;
    }

    if ($variantId > 0) {
        if ($action === 'remove') {
            fav_remove($variantId);
        } else {
            fav_add($variantId);
        }
    }
}

$back = $_SERVER['HTTP_REFERER'] ?? 'index.php';
header('Location: ' . $back);
exit;
