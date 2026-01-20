<?php
declare(strict_types=1);

namespace App\AI;

/**
 * Canonical AI output rules applied across agents.
 */
final class OutputRules
{
    public const RULE_SUGGEST_ONLY = 'suggest_only';
    public const RULE_HUMAN_APPROVAL = 'human_approval_required';
    public const RULE_CITATIONS_REQUIRED = 'citations_required';

    /**
     * @return array<string, string>
     */
    public static function descriptions(): array
    {
        return [
            self::RULE_SUGGEST_ONLY => 'AI outputs are suggestions only and never auto-apply changes.',
            self::RULE_HUMAN_APPROVAL => 'A human reviewer must approve AI outputs before publish or persistence.',
            self::RULE_CITATIONS_REQUIRED => 'Factual claims must include citations or be flagged as uncertain.',
        ];
    }

    /**
     * @return string[]
     */
    public static function all(): array
    {
        return array_keys(self::descriptions());
    }
}
