<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'AutoMart | Autopredator',
    'description' => 'Market intelligence and clean vehicle histories to move inventory faster.',
    'content' => __DIR__ . '/../pages/products/automart.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-product page-product-automart',
]);
