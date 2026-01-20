<?php
declare(strict_types=1);

namespace App\AI\Prompts;

/**
 * Simple value object for prompt templates.
 */
final class PromptTemplate
{
    public string $id;
    public string $version;
    public string $body;

    /**
     * @var array<string, mixed>
     */
    public array $metadata;

    /**
     * @param array<string, mixed> $metadata
     */
    public function __construct(string $id, string $version, string $body, array $metadata = [])
    {
        $this->id = $id;
        $this->version = $version;
        $this->body = $body;
        $this->metadata = $metadata;
    }

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'version' => $this->version,
            'body' => $this->body,
            'metadata' => $this->metadata,
        ];
    }
}
