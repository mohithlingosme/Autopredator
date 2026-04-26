<?php
declare(strict_types=1);

namespace App\AI\Logging;

use App\Support\Logger;

/**
 * Structured logger for AI runs.
 */
class AIEventLogger
{
    private Logger $logger;

    public function __construct(?Logger $logger = null)
    {
        $this->logger = $logger ?? new Logger('ai_events');
    }

    /**
     * @param array<string, mixed> $metadata
     */
    public function logSuccess(string $taskType, string $provider, array $metadata = []): void
    {
        $this->logger->info('AI run succeeded', [
            'task_type' => $taskType,
            'provider' => $provider,
            'metadata' => $metadata,
        ]);
    }

    /**
     * @param array<string, mixed> $metadata
     */
    public function logFailure(string $taskType, string $provider, string $errorMessage, array $metadata = []): void
    {
        $this->logger->error('AI run failed', [
            'task_type' => $taskType,
            'provider' => $provider,
            'error' => $errorMessage,
            'metadata' => $metadata,
        ]);
    }
}
