<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Thank You | Autopredator',
    'description' => 'Thank you for reaching out to Autopredator.',
    'content' => __DIR__ . '/pages/thank-you.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-thank-you',
]);
