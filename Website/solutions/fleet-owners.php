<?php
declare(strict_types=1);

require_once __DIR__ . '/../partials/layout.php';

renderPage([
    'title' => 'Solutions for Fleet Owners | Autopredator',
    'description' => 'Predictive maintenance, automation, and compliance guardrails for fleets.',
    'content' => __DIR__ . '/../pages/solutions/fleet-owners.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-solution page-solution-fleet',
]);
