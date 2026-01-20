<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Resources | Autopredator',
    'description' => 'Autopredator resources, guides, and collateral.',
    'content' => __DIR__ . '/pages/resources.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-resources',
]);
