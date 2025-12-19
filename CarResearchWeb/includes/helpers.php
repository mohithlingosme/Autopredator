<?php
declare(strict_types=1);

/**
 * Escape output for safe HTML rendering.
 *
 * Accepts mixed input and always returns a string to avoid template crashes.
 *
 * @param mixed $value
 */
function e($value): string
{
    if (is_bool($value)) {
        $value = $value ? '1' : '0';
    } elseif (is_numeric($value)) {
        $value = (string) $value;
    } elseif ($value === null) {
        $value = '';
    } elseif (!is_string($value)) {
        $value = (string) @json_encode($value);
    }

    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * Convert text to a URL-friendly slug.
 */
function slugify(string $text): string
{
    $text = trim($text);

    if ($text === '') {
        return 'n-a';
    }

    if (function_exists('iconv')) {
        $converted = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $text);
        if ($converted !== false) {
            $text = $converted;
        }
    }

    $text = preg_replace('/[^\\pL\\pN]+/u', '-', $text) ?? '';
    $text = trim($text, '-');
    $text = strtolower($text);
    $text = preg_replace('/[^a-z0-9-]+/', '', $text) ?? '';

    return $text !== '' ? $text : 'n-a';
}

/**
 * Redirect to a URL and exit.
 */
function redirect(string $url, int $statusCode = 302): void
{
    header('Location: ' . $url, true, $statusCode);
    exit;
}

/**
 * Check if the current request is a POST.
 */
function is_post(): bool
{
    return ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST';
}

/**
 * Get query parameter safely.
 */
function get_query(string $key, string $default = ''): string
{
    return isset($_GET[$key]) ? trim((string) $_GET[$key]) : $default;
}

/**
 * Get POST parameter safely.
 */
function post_param(string $key, string $default = ''): string
{
    return isset($_POST[$key]) ? trim((string) $_POST[$key]) : $default;
}

/**
 * Format price in Indian Rupees with Indian numbering system.
 */
function format_price(float $price): string
{
    if ($price <= 0) {
        return 'Price on request';
    }

    if ($price >= 10000000) {
        $value = $price / 10000000;
        return 'Rs.' . number_format($value, $value >= 10 ? 0 : 1) . ' Cr';
    }

    if ($price >= 100000) {
        $value = $price / 100000;
        return 'Rs.' . number_format($value, $value >= 10 ? 0 : 1) . ' L';
    }

    return 'Rs.' . number_format_indian($price);
}

/**
 * Format number with Indian numbering system (commas every 2 digits after thousands).
 */
function number_format_indian(float $number): string
{
    $number = (int) $number;
    $number_str = (string) $number;

    if ($number < 1000) {
        return $number_str;
    }

    $last_three = substr($number_str, -3);
    $remaining = substr($number_str, 0, -3);

    if ($remaining === '') {
        return $last_three;
    }

    $remaining = strrev($remaining);
    $formatted_remaining = '';
    for ($i = 0; $i < strlen($remaining); $i++) {
        if ($i > 0 && $i % 2 === 0) {
            $formatted_remaining .= ',';
        }
        $formatted_remaining .= $remaining[$i];
    }
    $formatted_remaining = strrev($formatted_remaining);

    return $formatted_remaining . ',' . $last_three;
}

/**
 * Build query string from array.
 */
function build_query(array $params): string
{
    return http_build_query(array_filter($params, static fn($v) => $v !== '' && $v !== null));
}

/**
 * Shorten long text with an ellipsis.
 */
function truncate(string $text, int $length = 100): string
{
    return strlen($text) <= $length ? $text : substr($text, 0, $length - 3) . '...';
}

/**
 * Render a value or a fallback dash when missing.
 *
 * @param mixed $value
 */
function display_value($value, string $fallback = '—'): string
{
    if ($value === null) {
        return $fallback;
    }
    if (is_string($value) && trim($value) === '') {
        return $fallback;
    }
    if (is_array($value) && $value === []) {
        return $fallback;
    }

    return e($value);
}
