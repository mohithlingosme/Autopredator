<?php
declare(strict_types=1);

namespace App\AI\Validators;

use App\AI\OutputRules;

/**
 * Lightweight validator to enforce baseline AI output rules.
 */
class SuggestionValidator
{
    /**
     * Validate that AI output follows suggest-only semantics.
     *
     * @param array<string, mixed> $payload
     * @return array{valid: bool, errors: string[], rules: array<string, string>}
     */
    public function validate(array $payload): array
    {
        $errors = [];

        if (!isset($payload['suggestions']) || !is_array($payload['suggestions'])) {
            $errors[] = 'Suggestions array is required.';
        }

        if (isset($payload['status']) && $payload['status'] === 'apply') {
            $errors[] = 'Direct application of AI output is blocked; suggestions only.';
        }

        if (isset($payload['citations']) && !is_array($payload['citations'])) {
            $errors[] = 'Citations must be an array when provided.';
        }

        return [
            'valid' => empty($errors),
            'errors' => $errors,
            'rules' => OutputRules::descriptions(),
        ];
    }
}
