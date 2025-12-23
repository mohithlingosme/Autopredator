<?php
declare(strict_types=1);

namespace App\Support;

final class CacheHelper
{
    public function checkETag(string $etag): bool
    {
        $requestETag = $_SERVER['HTTP_IF_NONE_MATCH'] ?? '';
        if ($requestETag === '"' . $etag . '"') {
            return true;
        }
        return false;
    }

    public function checkLastModified(string $lastModified): bool
    {
        $requestLastModified = $_SERVER['HTTP_IF_MODIFIED_SINCE'] ?? '';
        if ($requestLastModified === $lastModified) {
            return true;
        }
        return false;
    }
}
