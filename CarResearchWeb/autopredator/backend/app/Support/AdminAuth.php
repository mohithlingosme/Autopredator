<?php
declare(strict_types=1);

namespace App\Support;

final class AdminAuth
{
    private const USERNAME = 'admin';
    private const PASSWORD = 'password'; // In production, use proper hashing

    public function check(): bool
    {
        if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW'])) {
            header('WWW-Authenticate: Basic realm="Admin Area"');
            return false;
        }

        return $_SERVER['PHP_AUTH_USER'] === self::USERNAME && $_SERVER['PHP_AUTH_PW'] === self::PASSWORD;
    }
}
