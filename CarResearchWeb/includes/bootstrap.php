<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/Support/Autoload.php';
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/../../app/Repositories/CarRepositoryInterface.php';

use App\Repositories\DbCarRepository;
use App\Repositories\JsonCarRepository;

/**
 * Bootstrap file for initializing the application.
 * Chooses DB repository when USE_JSON=false, otherwise falls back to bundled JSON.
 */

$dataDir = defined('DATA_DIR') ? DATA_DIR : (__DIR__ . '/../mocks');

if (defined('USE_JSON') && USE_JSON) {
    $repo = new JsonCarRepository($dataDir);
} else {
    $repo = new DbCarRepository(get_db());
}

/**
 * Get the shared repository instance.
 */
function repo(): \App\Repositories\CarRepositoryInterface
{
    global $repo;
    return $repo;
}
