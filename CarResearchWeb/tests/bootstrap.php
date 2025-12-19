<?php
declare(strict_types=1);

$vendor = __DIR__ . '/../vendor/autoload.php';
if (file_exists($vendor)) {
    require_once $vendor;
}

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../app/Support/Autoload.php';
require_once __DIR__ . '/../includes/helpers.php';
require_once __DIR__ . '/../includes/repository.php';
