<?php
declare(strict_types=1);

/**
 * Standalone CLI script to manually regenerate the Graphify graph.
 *
 * Usage (from project root):
 *   php autopredator/backend/scripts/regenerate-graphify.php
 *
 * Or with a custom target path:
 *   php autopredator/backend/scripts/regenerate-graphify.php /path/to/project
 */

require_once __DIR__ . '/../app/Support/GraphifyTrigger.php';

$targetPath = $argv[1] ?? '';

echo "=== Autopredator Graphify Regenerator ===\n\n";

$status = GraphifyTrigger::status();
echo "Config enabled: " . ($status['enabled'] ? 'YES' : 'NO') . "\n";
echo "Binary available: " . ($status['available'] ? 'YES' : 'NO') . "\n";
if ($status['last_run']) {
    echo "Last run: " . $status['last_run'] . "\n";
}
echo "\n";

if (!$status['enabled']) {
    echo "ABORT: GRAPHIFY_AUTO_GENERATE is disabled in config.\n";
    echo "Enable it by setting environment variable GRAPHIFY_AUTO_GENERATE=true\n";
    echo "or editing autopredator/backend/config.php.\n";
    exit(1);
}

if (!$status['available']) {
    echo "ABORT: graphify binary not found on PATH.\n";
    echo "Install it with:  pip install graphifyy\n";
    exit(1);
}

echo "Starting graphify update...\n";
$result = GraphifyTrigger::run($targetPath);

echo "\nResult: " . ($result['success'] ? 'SUCCESS' : 'FAILURE') . "\n";
echo "Message: " . $result['message'] . "\n";
if ($result['details']) {
    echo "Details: " . $result['details'] . "\n";
}

exit($result['success'] ? 0 : 1);

