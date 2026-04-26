<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Support\JsonLoader;
use App\Support\Logger;

/**
 * Safely serves model detail JSON files based on a strict allowlist.
 */
final class DetailRepository
{
    private const SLUG_PATTERN = '/^[a-z0-9]+(?:-[a-z0-9]+)*$/';

    private JsonLoader $loader;

    /** @var array<string, string> */
    private array $allowlist = [];

    public function __construct(JsonLoader $loader, string $indexFile = 'details_index.json')
    {
        $this->loader = $loader;
        $this->allowlist = $this->loadAllowlist($indexFile);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function getDetailsBySlug(string $slug): ?array
    {
        $slug = strtolower(trim($slug));
        if (!preg_match(self::SLUG_PATTERN, $slug)) {
            Logger::channel('data')->error('Rejected invalid details slug', ['slug' => $slug]);
            return null;
        }

        $file = $this->allowlist[$slug] ?? null;
        if ($file === null) {
            return null;
        }

        $data = $this->loader->load($file);

        return $data !== [] ? $data : null;
    }

    /**
     * @return array<string, string>
     */
    private function loadAllowlist(string $indexFile): array
    {
        $map = $this->loader->load($indexFile);
        if ($map === []) {
            return [];
        }

        $cleaned = [];
        foreach ($map as $slug => $file) {
            if (!is_string($slug) || !is_string($file)) {
                continue;
            }

            $slug = strtolower(trim($slug));
            if (!preg_match(self::SLUG_PATTERN, $slug)) {
                continue;
            }

            // Reject absolute paths to keep lookups inside DATA_DIR
            if (preg_match('#^[a-zA-Z]:\\\\|^/#', $file) === 1) {
                continue;
            }

            $cleaned[$slug] = ltrim($file, '/\\');
        }

        if ($cleaned === []) {
            Logger::channel('data')->error('Details allowlist is empty or invalid');
        }

        return $cleaned;
    }
}

