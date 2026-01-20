<?php
declare(strict_types=1);

namespace App\Support;

/**
 * Lightweight logger that writes to PHP error log and an optional local file.
 */
final class Logger
{
    private const LOG_PREFIX = '[Autopredator]';
    private const LOG_DIR = __DIR__ . '/../../storage/logs';
    private const LOG_FILE = self::LOG_DIR . '/app.log';

    private string $channel;

    public function __construct(string $channel = 'app')
    {
        $this->channel = $channel;
    }

    /**
     * Log informational messages.
     *
     * @param array<string, mixed> $context
     */
    public function info(string $message, array $context = []): void
    {
        self::log('INFO', $this->channel, $message, $context);
    }

    /**
     * Log warning messages.
     *
     * @param array<string, mixed> $context
     */
    public function warning(string $message, array $context = []): void
    {
        self::log('WARNING', $this->channel, $message, $context);
    }

    /**
     * Log error messages.
     *
     * @param array<string, mixed> $context
     */
    public function error(string $message, array $context = []): void
    {
        self::log('ERROR', $this->channel, $message, $context);
    }

    public static function channel(string $channel = 'app'): self
    {
        return new self($channel);
    }

    /**
     * Internal logger used by both static and instance methods.
     *
     * @param array<string, mixed> $context
     */
    private static function log(string $level, string $channel, string $message, array $context = []): void
    {
        $payload = sprintf('%s[%s][%s] %s', self::LOG_PREFIX, strtoupper($level), $channel, $message);
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
