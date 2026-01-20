<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'For Fleets | Autopredator',
    'description' => 'Predictive automation and uptime control for fleet operators.',
    'content' => __DIR__ . '/pages/for-fleets.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-for-fleets',
]);
