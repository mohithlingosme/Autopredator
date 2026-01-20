<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Product Suite / Apps | Autopredator',
    'description' => 'Explore the Autopredator product suite and app modules.',
    'content' => __DIR__ . '/pages/product-suite.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-product-suite',
]);
