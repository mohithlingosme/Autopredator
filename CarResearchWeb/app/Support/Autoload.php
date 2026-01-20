<?php
declare(strict_types=1);

/**
 * Minimal PSR-4 style autoloader for the App namespace.
 */
spl_autoload_register(static function (string $class): void {
    if (strpos($class, 'App\\') !== 0) {
        return;
    }

    $relative = str_replace('\\', '/', substr($class, 4));

    $baseDirs = [
        __DIR__ . '/../',            // existing App classes
        dirname(__DIR__, 2) . '/src/', // new data layer
    ];

    foreach ($baseDirs as $base) {
        $path = rtrim($base, '/\\') . '/' . $relative . '.php';
        if (is_file($path)) {
            require_once $path;
            return;
        }
    }
});
