<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Industries We Serve | Autopredator',
    'description' => 'See how Autopredator supports personal, commercial, agricultural, and construction vehicles.',
    'content' => __DIR__ . '/pages/industries.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-industries',
]);
