<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'Finance Desk | Autopredator',
    'description' => 'Loan and lease workflows with live risk signals from vehicle data.',
    'content' => __DIR__ . '/../pages/products/finance-desk.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-product page-product-finance-desk',
]);
