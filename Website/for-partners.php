<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'For Partners | Autopredator',
    'description' => 'Partner integrations, co-selling, and services for predictive automation.',
    'content' => __DIR__ . '/pages/for-partners.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-for-partners',
]);
