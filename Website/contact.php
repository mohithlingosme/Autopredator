<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

renderPage([
    'title' => 'Contact | Autopredator',
    'description' => 'Contact Autopredator for demos, pricing, and support for your fleet.',
    'content' => __DIR__ . '/pages/contact.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-contact',
]);
