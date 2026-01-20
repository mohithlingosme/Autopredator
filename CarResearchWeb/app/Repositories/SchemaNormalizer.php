<?php

namespace App\Repositories;

class SchemaNormalizer
{
    /**
     * Converts a string to a URL-friendly slug.
     *
     * @param string|null $text
     * @return string
     */
    public static function toSlug(?string $text): string
    {
        if ($text === null) {
            return '';
        }
        // Replace non-letter or digits by -
        $text = preg_replace('~[^\pL\d]+~u', '-', $text);
        // Transliterate
        $text = iconv('utf-8', 'us-ascii//TRANSLIT', $text);
        // Remove unwanted characters
        $text = preg_replace('~[^-\w]+~', '', $text);
        // Trim
        $text = trim($text, '-');
        // Remove duplicate -
        $text = preg_replace('~-+~', '-', $text);
        // Lowercase
        $text = strtolower($text);

        return empty($text) ? 'n-a' : $text;
    }

    /**
     * Parses a price string (e.g., "₹11.00 - 20.15 Lakh") into an integer array of [min, max] in rupees.
     *
     * @param string|null $priceText
     * @return array|null[] [?int, ?int]
     */
    public static function parsePriceRangeToRupees(?string $priceText): array
    {
        if (empty($priceText) || strtolower($priceText) === 'n/a') {
            return [null, null];
        }

        $priceText = str_replace(['₹', ',', '(Est.)'], '', $priceText);
        $multiplier = 1;
        if (stripos($priceText, 'Lakh') !== false) {
            $multiplier = 100000;
        } elseif (stripos($priceText, 'Crore') !== false) {
            $multiplier = 10000000;
        }

        $priceText = str_ireplace(['Lakh', 'Crore'], '', $priceText);
        $parts = explode('-', $priceText);

        $minPrice = null;
        $maxPrice = null;

        if (isset($parts[0])) {
            $minPrice = self::toIntOrNull(trim($parts[0]) * $multiplier);
        }

        if (isset($parts[1])) {
            $maxPrice = self::toIntOrNull(trim($parts[1]) * $multiplier);
        } else {
            $maxPrice = $minPrice;
        }

        return [$minPrice, $maxPrice];
    }

    /**
     * Converts a value to an integer or null.
     *
     * @param mixed $value
     * @return int|null
     */
    public static function toIntOrNull($value): ?int
    {
        if ($value === null || $value === '' || !is_numeric($value)) {
            return null;
        }
        return (int)$value;
    }

    /**
     * Converts a value to a float or null.
     *
     * @param mixed $value
     * @return float|null
     */
    public static function toFloatOrNull($value): ?float
    {
        if ($value === null || $value === '' || !is_numeric($value)) {
            return null;
        }
        return (float)$value;
    }

    /**
     * Converts a string or array to a clean array of strings.
     *
     * @param string|array|null $value
     * @param string $delimiter
     * @return array
     */
    public static function toStringArray($value, string $delimiter = '/'): array
    {
        if (is_array($value)) {
            return array_filter(array_map('trim', $value));
        }
        if (is_string($value)) {
            return array_filter(array_map('trim', explode($delimiter, $value)));
        }
        return [];
    }

    /**
     * Extracts a numeric value from a string (e.g., "113-160 bhp" -> [113, 160]).
     *
     * @param string|null $text
     * @return array [?float, ?float]
     */
    public static function extractNumericRange(?string $text): array
    {
        if (empty($text)) return [null, null];
        preg_match_all('/(\d+\.?\d*)/', $text, $matches);
        $numbers = $matches[0];
        $min = isset($numbers[0]) ? self::toFloatOrNull($numbers[0]) : null;
        $max = isset($numbers[1]) ? self::toFloatOrNull($numbers[1]) : $min;
        return [$min, $max];
    }
}