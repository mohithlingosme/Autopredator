<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'Solutions for Individuals | Autopredator',
    'description' => 'Preventive reminders, cost tracking, and compliance support for individual vehicle owners.',
    'content' => __DIR__ . '/../pages/solutions/individuals.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-solution page-solution-individuals',
]);
