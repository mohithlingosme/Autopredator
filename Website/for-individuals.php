<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'For Individuals | Autopredator',
    'description' => 'Enterprise-grade predictive tools for independent operators.',
    'content' => __DIR__ . '/pages/for-individuals.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-for-individuals',
]);
