<?php
declare(strict_types=1);

/**
 * Favorites API Endpoint
 * Manages user favorites (add/remove/list)
 */

require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/car_repository.php';
require_once __DIR__ . '/../includes/config.php';
require_once __DIR__ . '/../includes/db.php';

header('Content-Type: application/json; charset=utf-8');

$action = $_GET['action'] ?? $_POST['action'] ?? '';
$variantId = (int) ($_GET['variant_id'] ?? $_POST['variant_id'] ?? 0);

auth_session_start();

if ($action === 'add' && $variantId > 0) {
    fav_add($variantId);
    json_response(['success' => true, 'message' => 'Added to favorites']);
} elseif ($action === 'remove' && $variantId > 0) {
    fav_remove($variantId);
    json_response(['success' => true, 'message' => 'Removed from favorites']);
} elseif ($action === 'list') {
    $favorites = fav_get_list();
    json_response(['success' => true, 'favorites' => $favorites]);
} elseif ($action === 'check' && $variantId > 0) {
    $favorites = fav_get_list();
    json_response(['success' => true, 'is_favorite' => in_array($variantId, $favorites)]);
} else {
    json_response(['success' => false, 'error' => 'Invalid request'], 400);
}

function json_response(array $data, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}
