<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'Solutions for Dealers & Brokers | Autopredator',
    'description' => 'Inventory health, pricing intelligence, and reconditioning workflows.',
    'content' => __DIR__ . '/../pages/solutions/dealers-and-brokers.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-solution page-solution-dealers',
]);
