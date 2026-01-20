<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/Support/Autoload.php';
require_once __DIR__ . '/../../app/Repositories/CarRepositoryInterface.php';

/**
 * Bootstrap file for initializing the application.
 * Sets up the JsonCarRepository with the correct data directory.
 */

// Define data directory (supports both data.json and new_carset.json in mocks/)
$dataDir = __DIR__ . '/../mocks';

// Initialize the repository
$repo = new \App\Repositories\JsonCarRepository($dataDir);

/**
 * Get the shared JsonCarRepository instance.
 */
function repo(): \App\Repositories\JsonCarRepository
{
    global $repo;
    return $repo;
}
