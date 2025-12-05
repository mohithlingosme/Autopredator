<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'About | Autopredator',
    'description' => 'Meet Autopredator - our story, mission, and vision to make fleets predictable.',
    'content' => __DIR__ . '/pages/about.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-about',
]);
