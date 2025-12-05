<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Autopredator | Predictive Automation',
    'description' => 'Predictive fleet automation that reduces downtime, controls costs, and keeps every vehicle compliant.',
    'content' => __DIR__ . '/pages/home.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-home',
]);
