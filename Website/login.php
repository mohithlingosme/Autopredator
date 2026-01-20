<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

$loginError = isset($_GET['error']) && $_GET['error'] === '1';

renderPage([
    'title' => 'Login | Autopredator',
    'description' => 'Login to Autopredator.',
    'content' => __DIR__ . '/pages/login.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-login',
    'data' => ['loginError' => $loginError],
]);
