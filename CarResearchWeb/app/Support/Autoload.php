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
    $path = __DIR__ . '/../' . $relative . '.php';

    if (is_file($path)) {
        require_once $path;
    }
});
