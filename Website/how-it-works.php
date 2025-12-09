<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'How Autopredator Works',
    'description' => 'Understand the data flow, automation, and value delivery behind Autopredator.',
    'content' => __DIR__ . '/pages/how-it-works.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-how-it-works',
]);
