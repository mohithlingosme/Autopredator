<?php
declare(strict_types=1);

namespace App\AI;

/**
 * Contract that all AI providers must implement.
 *
 * Providers should wrap any vendor-specific SDKs behind these safe methods
 * so the rest of the app is not tied to a single vendor.
 */
interface ProviderInterface
{
    /**
     * Generate free-form text.
     *
     * @param array<string, mixed> $options
     */
    public function generateText(string $prompt, array $options = []): string;

    /**
     * Generate structured JSON output.
     *
     * @param array<string, mixed> $options
     * @return array<string, mixed>
     */
    public function generateJson(string $prompt, array $options = []): array;

    /**
     * Human-readable provider name.
     */
    public function getProviderName(): string;

    /**
     * Whether the provider is available (e.g., credentials present).
     */
    public function isAvailable(): bool;
}
