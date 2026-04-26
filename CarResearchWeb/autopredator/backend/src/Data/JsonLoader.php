<?php
declare(strict_types=1);

namespace App\Data;

use App\Support\Logger;
use JsonException;
use RuntimeException;

/**
 * Centralized JSON loader with safety checks and friendly error handling.
 */
final class JsonLoader
{
    private string $baseDir;

    public function __construct(string $baseDir)
    {
        $realBase = realpath($baseDir);
        $this->baseDir = $realBase !== false ? rtrim($realBase, '/\\') : rtrim($baseDir, '/\\');
    }

    public function getBaseDir(): string
    {
        return $this->baseDir;
    }

    /**
     * Load a JSON file relative to the configured base directory.
     *
     * @return array<int|string, mixed>
     */
    public function load(string $relativePath): array
    {
        try {
            $path = $this->resolvePath($relativePath);
        } catch (RuntimeException $e) {
            Logger::channel('data')->error('JSON load blocked by path validation', ['error' => $e->getMessage(), 'relative' => $relativePath]);
            return [];
        }

        if (!is_file($path) || !is_readable($path)) {
            Logger::channel('data')->error('JSON file missing or unreadable', ['file' => $path]);
            return [];
        }

        $content = @file_get_contents($path);
        if ($content === false) {
            Logger::channel('data')->error('Failed to read JSON file', ['file' => $path]);
            return [];
        }

        try {
            /** @var array<int|string, mixed> $decoded */
            $decoded = json_decode($content, true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException $e) {
            Logger::channel('data')->error('Invalid JSON content', ['file' => $path, 'error' => $e->getMessage()]);
            return [];
        }

        if (!is_array($decoded)) {
            Logger::channel('data')->error('JSON root must be array or object', ['file' => $path]);
            return [];
        }

        return $decoded;
    }

    private function resolvePath(string $relativePath): string
    {
        $sanitizedSegments = [];
        $parts = explode('/', str_replace('\\', '/', $relativePath));

        foreach ($parts as $segment) {
            if ($segment === '' || $segment === '.') {
                continue;
            }

            if ($segment === '..') {
                array_pop($sanitizedSegments);
                continue;
            }

            $sanitizedSegments[] = $segment;
        }

        $candidate = $this->baseDir . DIRECTORY_SEPARATOR . implode(DIRECTORY_SEPARATOR, $sanitizedSegments);
        $resolvedDir = realpath(dirname($candidate)) ?: dirname($candidate);
        $normalizedBase = rtrim($this->baseDir, '/\\') . DIRECTORY_SEPARATOR;
        $targetDir = rtrim($resolvedDir, '/\\') . DIRECTORY_SEPARATOR;

        if (strpos($targetDir, $normalizedBase) !== 0) {
            throw new RuntimeException('Resolved path escapes data directory');
        }

        return $targetDir . basename($candidate);
    }
}
