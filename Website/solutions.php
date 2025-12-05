<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Solutions | Autopredator',
    'description' => 'Explore Autopredator solutions for vehicle health, fleet automation, cost analytics, and compliance.',
    'content' => __DIR__ . '/pages/solutions.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-solutions',
]);
