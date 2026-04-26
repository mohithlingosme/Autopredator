<?php
declare(strict_types=1);

namespace App\AI\Tools;

/**
 * Helper for exposing AI feature flag state to callers.
 */
final class FeatureFlags
{
    /**
     * @return array<string, bool>
     */
    public static function current(): array
    {
        return [
            'AI_ENABLED' => defined('AI_ENABLED') && AI_ENABLED,
            'AI_CONTENT_ENABLED' => defined('AI_CONTENT_ENABLED') && AI_CONTENT_ENABLED,
            'AI_SUPPORT_ENABLED' => defined('AI_SUPPORT_ENABLED') && AI_SUPPORT_ENABLED,
        ];
    }
}
