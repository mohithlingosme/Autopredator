<?php
declare(strict_types=1);

namespace App\AI;

/**
 * Stub AI Provider
 *
 * Provides deterministic placeholder outputs when no real LLM is configured.
 * Used for development, testing, and fallback scenarios.
 */
class StubProvider implements ProviderInterface
{
    /**
     * Generate deterministic text response
     */
    public function generateText(string $prompt, array $options = []): string
    {
        // Simple hash-based deterministic response for testing
        $hash = crc32($prompt);
        $responses = [
            "This is a placeholder AI response for prompt hash: {$hash}. Please configure a real AI provider for production use.",
            "AI-generated content placeholder. Original prompt length: " . strlen($prompt) . " characters.",
            "Stub response: This feature requires AI provider configuration. Contact administrator to enable AI capabilities.",
        ];

        return $responses[$hash % count($responses)];
    }

    /**
     * Generate deterministic JSON response
     */
    public function generateJson(string $prompt, array $options = []): array
    {
        // Return a basic JSON structure for testing
        return [
            'status' => 'stub',
            'message' => 'This is a placeholder JSON response from the stub AI provider.',
            'prompt_hash' => crc32($prompt),
            'timestamp' => date('c'),
            'suggestions' => [
                'Please configure a real AI provider to get meaningful results.',
                'This is for development and testing purposes only.'
            ]
        ];
    }

    /**
     * Get provider name
     */
    public function getProviderName(): string
    {
        return 'stub';
    }

    /**
     * Stub provider is always available
     */
    public function isAvailable(): bool
    {
        return true;
    }
}
