<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (empty($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

renderPage([
    'title' => 'Dashboard | Autopredator',
    'description' => 'Dashboard placeholder for Autopredator.',
    'content' => __DIR__ . '/pages/dashboard-placeholder.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-dashboard',
]);
