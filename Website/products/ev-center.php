<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'EV Center | Autopredator',
    'description' => 'EV health, charging optimization, and range confidence.',
    'content' => __DIR__ . '/../pages/products/ev-center.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-product page-product-ev-center',
]);
