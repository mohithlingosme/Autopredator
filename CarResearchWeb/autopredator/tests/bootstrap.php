<?php
declare(strict_types=1);

$vendor = __DIR__ . '/../backend/vendor/autoload.php';
if (file_exists($vendor)) {
    require_once $vendor;
}

require_once __DIR__ . '/../backend/config.php';
require_once __DIR__ . '/../backend/app/Support/Autoload.php';
require_once __DIR__ . '/../backend/includes/helpers.php';
require_once __DIR__ . '/../backend/includes/bootstrap.php';
