<?php
declare(strict_types=1);

namespace App\AI;

/**
 * AI Configuration
 *
 * Manages AI provider configuration and model routing based on task types.
 */
class AIConfig
{
    /**
     * Available providers configuration
     */
    private static array $providers = [
        'stub' => [
            'class' => StubProvider::class,
            'enabled' => true,
            'default' => true,
        ],
        // Add real providers here when configured
        // 'openai' => [
        //     'class' => OpenAIProvider::class,
        //     'enabled' => false,
        //     'api_key' => getenv('OPENAI_API_KEY'),
        //     'models' => ['gpt-3.5-turbo', 'gpt-4'],
        // ],
    ];

    /**
     * Model routing based on task type
     * Maps task types to preferred models/providers
     */
    private static array $taskRouting = [
        'content_draft' => [
            'preferred_provider' => 'stub', // Use cheap/fast model for drafts
            'fallback_provider' => 'stub',
            'timeout' => 30,
            'max_tokens' => 2000,
            'feature' => 'content',
        ],
        'content_rewrite' => [
            'preferred_provider' => 'stub',
            'fallback_provider' => 'stub',
            'timeout' => 30,
            'max_tokens' => 1500,
            'feature' => 'content',
        ],
        'data_enrichment' => [
            'preferred_provider' => 'stub', // Use strong model for data analysis
            'fallback_provider' => 'stub',
            'timeout' => 45,
            'max_tokens' => 1000,
            'feature' => 'support',
        ],
        'fact_check' => [
            'preferred_provider' => 'stub',
            'fallback_provider' => 'stub',
            'timeout' => 20,
            'max_tokens' => 500,
            'feature' => 'support',
        ],
    ];

    /**
     * Get provider instance for a task type
     */
    public static function getProviderForTask(string $taskType): ProviderInterface
    {
        $routing = self::$taskRouting[$taskType] ?? self::$taskRouting['content_draft'];

        // Try preferred provider first
        $preferredProvider = $routing['preferred_provider'];
        if (isset(self::$providers[$preferredProvider]) &&
            self::$providers[$preferredProvider]['enabled']) {
            $providerClass = self::$providers[$preferredProvider]['class'];
            $provider = new $providerClass();
            if ($provider->isAvailable()) {
                return $provider;
            }
        }

        // Fallback to default provider
        foreach (self::$providers as $config) {
            if ($config['enabled'] && $config['default']) {
                $providerClass = $config['class'];
                $provider = new $providerClass();
                if ($provider->isAvailable()) {
                    return $provider;
                }
            }
        }

        // Ultimate fallback: stub provider
        return new StubProvider();
    }

    /**
     * Get task configuration
     */
    public static function getTaskConfig(string $taskType): array
    {
        return self::$taskRouting[$taskType] ?? self::$taskRouting['content_draft'];
    }

    /**
     * Check whether a task is allowed based on feature flags.
     */
    public static function isTaskEnabled(string $taskType): bool
    {
        if (!self::isAIEnabled()) {
            return false;
        }

        $config = self::$taskRouting[$taskType] ?? null;
        if ($config !== null && isset($config['feature'])) {
            return self::isFeatureEnabled($config['feature']);
        }

        // Default to allowed if no specific feature gate is mapped.
        return true;
    }

    /**
     * Check if AI is enabled globally
     */
    public static function isAIEnabled(): bool
    {
        return defined('AI_ENABLED') && AI_ENABLED;
    }

    /**
     * Check if specific AI feature is enabled
     */
    public static function isFeatureEnabled(string $feature): bool
    {
        if (!self::isAIEnabled()) {
            return false;
        }

        return match($feature) {
            'content' => defined('AI_CONTENT_ENABLED') && AI_CONTENT_ENABLED,
            'support' => defined('AI_SUPPORT_ENABLED') && AI_SUPPORT_ENABLED,
            default => false,
        };
    }
}
