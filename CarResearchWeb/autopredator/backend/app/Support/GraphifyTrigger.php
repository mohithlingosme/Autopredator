<?php
declare(strict_types=1);

require_once __DIR__ . '/../Services/GraphifyService.php';

/**
 * GraphifyTrigger - Convenience helper to conditionally regenerate the graph.
 *
 * Checks GRAPHIFY_AUTO_GENERATE config flag, runs graphify, and returns
 * a user-friendly result array suitable for admin UI messages or API JSON.
 */
class GraphifyTrigger
{
    /**
     * Attempt to auto-generate the graphify graph.
     *
     * @param string $targetPath Optional override path (defaults to GRAPHIFY_TARGET_PATH)
     * @return array{success:bool,skipped:bool,message:string,details:string}
     */
    public static function run(string $targetPath = ''): array
    {
        $svc = new GraphifyService();
        $result = $svc->autoGenerate($targetPath);

        if ($result['skipped']) {
            return [
                'success'  => false,
                'skipped'  => true,
                'message'  => 'Graphify auto-generation is disabled or graphify is not installed.',
                'details'  => $result['error'] ?? '',
            ];
        }

        if ($result['success']) {
            return [
                'success'  => true,
                'skipped'  => false,
                'message'  => 'Graphify graph.json regenerated successfully.',
                'details'  => $result['output'] ?? '',
            ];
        }

        return [
            'success'  => false,
            'skipped'  => false,
            'message'  => 'Graphify generation failed.',
            'details'  => $result['error'] ?? '',
        ];
    }

    /**
     * Check whether graphify auto-generation is enabled in config.
     */
    public static function isEnabled(): bool
    {
        return defined('GRAPHIFY_AUTO_GENERATE') && GRAPHIFY_AUTO_GENERATE === true;
    }

    /**
     * Check whether the graphify binary is available on the system.
     */
    public static function isBinaryAvailable(): bool
    {
        $svc = new GraphifyService();
        return $svc->isAvailable();
    }

    /**
     * Full status array for admin dashboard widgets.
     *
     * @return array{enabled:bool,available:bool,last_run:string|null}
     */
    public static function status(): array
    {
        $enabled   = self::isEnabled();
        $available = self::isBinaryAvailable();

        $lastRun = null;
        $graphJson = (defined('GRAPHIFY_TARGET_PATH') ? GRAPHIFY_TARGET_PATH : __DIR__ . '/../../..') . '/graphify-out/graph.json';
        if (is_file($graphJson)) {
            $lastRun = date('Y-m-d H:i:s', filemtime($graphJson));
        }

        return [
            'enabled'    => $enabled,
            'available'  => $available,
            'last_run'   => $lastRun,
        ];
    }
}

