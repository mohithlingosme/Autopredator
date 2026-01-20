<?php
declare(strict_types=1);

namespace App\Support;

final class RateLimiter
{
    private string $storageDir;

    public function __construct()
    {
        $this->storageDir = __DIR__ . '/../../storage/ratelimit';
        if (!is_dir($this->storageDir)) {
            mkdir($this->storageDir, 0755, true);
        }
    }

    public function check(string $identifier, string $action, int $maxRequests, int $windowSeconds): bool
    {
        $key = md5($identifier . $action);
        $file = $this->storageDir . '/' . $key . '.json';

        $now = time();
        $data = [];

        if (file_exists($file)) {
            $data = json_decode(file_get_contents($file), true) ?: [];
        }

        // Clean old requests
        $data = array_filter($data, fn($timestamp) => $timestamp > ($now - $windowSeconds));

        // Check if under limit
        if (count($data) >= $maxRequests) {
            return false;
        }

        // Add current request
        $data[] = $now;
        file_put_contents($file, json_encode($data));

        return true;
    }
}
