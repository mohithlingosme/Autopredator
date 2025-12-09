<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Pricing | Autopredator',
    'description' => 'Simple pricing with a tailored plan for your fleet or operation.',
    'content' => __DIR__ . '/pages/pricing.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-pricing',
]);
