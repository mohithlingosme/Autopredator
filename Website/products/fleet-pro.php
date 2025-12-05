<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'Fleet Pro | Autopredator',
    'description' => 'Predictive fleet operations with unified alerts, workflows, and analytics.',
    'content' => __DIR__ . '/../pages/products/fleet-pro.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-product page-product-fleet-pro',
]);
