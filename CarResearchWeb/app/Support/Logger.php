<?php
declare(strict_types=1);

namespace App\Support;

/**
 * Lightweight logger that writes to PHP error log and an optional local file.
 */
final class Logger
{
    private const LOG_PREFIX = '[Autopredator] ';
    private const LOG_DIR = __DIR__ . '/../../storage/logs';
    private const LOG_FILE = self::LOG_DIR . '/app.log';

    /**
    * Log a message (and optional context) to error_log and a local file.
    *
    * @param array<string, mixed> $context
    */
    public static function error(string $message, array $context = []): void
    {
        $payload = self::LOG_PREFIX . $message;
        if (!empty($context)) {
            $payload .= ' | ' . json_encode(self::stringifyContext($context), JSON_UNESCAPED_SLASHES);
        }

        error_log($payload);
        self::writeToFile($payload);
    }

    /**
     * @param array<string, mixed> $context
     * @return array<string, mixed>
     */
    private static function stringifyContext(array $context): array
    {
        $stringified = [];
        foreach ($context as $key => $value) {
            if (is_scalar($value) || $value === null) {
                $stringified[$key] = $value;
                continue;
            }
            $stringified[$key] = json_encode($value, JSON_UNESCAPED_SLASHES) ?: '[unserializable]';
        }

        return $stringified;
    }

    private static function writeToFile(string $payload): void
    {
        if (!is_dir(self::LOG_DIR)) {
            @mkdir(self::LOG_DIR, 0775, true);
        }

        @file_put_contents(self::LOG_FILE, '[' . date('Y-m-d H:i:s') . '] ' . $payload . PHP_EOL, FILE_APPEND);
    }
}
