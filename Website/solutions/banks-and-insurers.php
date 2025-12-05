<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'Solutions for Banks & Insurers | Autopredator',
    'description' => 'Risk signals, compliance monitoring, and portfolio visibility for financed and insured vehicles.',
    'content' => __DIR__ . '/../pages/solutions/banks-and-insurers.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-solution page-solution-banks',
]);
