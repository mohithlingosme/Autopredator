<?php
declare(strict_types=1);

namespace App\Services;

use App\AI\AIConfig;
use App\AI\ProviderInterface;
use App\Support\Logger;

/**
 * AI Service
 *
 * Provides safe, reliable access to AI providers with error handling,
 * retries, timeouts, and logging.
 */
class AIService
{
    private Logger $logger;

    public function __construct()
    {
        $this->logger = new Logger('ai_service');
    }

    /**
     * Generate text with safe error handling
     */
    public function generateText(string $taskType, string $prompt, array $options = []): array
    {
        if (!AIConfig::isTaskEnabled($taskType)) {
            return $this->createErrorResponse('AI features are disabled for this task');
        }

        try {
            $provider = AIConfig::getProviderForTask($taskType);
            $config = AIConfig::getTaskConfig($taskType);

            // Set timeout
            $timeout = $config['timeout'] ?? 30;
            $this->setTimeout($timeout);

            // Attempt generation with retry logic
            $result = $this->executeWithRetry(
                fn() => $provider->generateText($prompt, $options),
                $config['max_retries'] ?? 2
            );

            if (!is_string($result)) {
                throw new \RuntimeException('Provider returned non-text result');
            }

            $this->clearTimeout();

            $this->logger->info('AI text generation successful', [
                'task_type' => $taskType,
                'provider' => $provider->getProviderName(),
                'prompt_length' => strlen($prompt),
                'result_length' => strlen($result),
            ]);

            return [
                'success' => true,
                'data' => $result,
                'provider' => $provider->getProviderName(),
                'task_type' => $taskType,
                'timestamp' => date('c'),
            ];

        } catch (\Throwable $e) {
            $this->clearTimeout();
            $this->logger->error('AI text generation failed', [
                'task_type' => $taskType,
                'error' => $e->getMessage(),
                'prompt_length' => strlen($prompt),
            ]);

            return $this->createErrorResponse('AI text generation failed: ' . $e->getMessage());
        }
    }

    /**
     * Generate JSON with safe error handling
     */
    public function generateJson(string $taskType, string $prompt, array $options = []): array
    {
        if (!AIConfig::isTaskEnabled($taskType)) {
            return $this->createErrorResponse('AI features are disabled for this task');
        }

        try {
            $provider = AIConfig::getProviderForTask($taskType);
            $config = AIConfig::getTaskConfig($taskType);

            $timeout = $config['timeout'] ?? 30;
            $this->setTimeout($timeout);

            $result = $this->executeWithRetry(
                fn() => $provider->generateJson($prompt, $options),
                $config['max_retries'] ?? 2
            );

            $this->clearTimeout();

            // Validate JSON structure
            if (!is_array($result)) {
                throw new \RuntimeException('Provider returned invalid JSON structure');
            }

            $this->logger->info('AI JSON generation successful', [
                'task_type' => $taskType,
                'provider' => $provider->getProviderName(),
                'prompt_length' => strlen($prompt),
            ]);

            return [
                'success' => true,
                'data' => $result,
                'provider' => $provider->getProviderName(),
                'task_type' => $taskType,
                'timestamp' => date('c'),
            ];

        } catch (\Throwable $e) {
            $this->clearTimeout();
            $this->logger->error('AI JSON generation failed', [
                'task_type' => $taskType,
                'error' => $e->getMessage(),
            ]);

            return $this->createErrorResponse('AI JSON generation failed: ' . $e->getMessage());
        }
    }

    /**
     * Execute operation with retry logic
     */
    private function executeWithRetry(callable $operation, int $maxRetries = 2): mixed
    {
        $lastException = null;

        for ($attempt = 0; $attempt <= $maxRetries; $attempt++) {
            try {
                return $operation();
            } catch (\Throwable $e) {
                $lastException = $e;

                if ($attempt < $maxRetries) {
                    $this->logger->warning('AI operation failed, retrying', [
                        'attempt' => $attempt + 1,
                        'max_retries' => $maxRetries,
                        'error' => $e->getMessage(),
                    ]);

                    // Exponential backoff
                    sleep(pow(2, $attempt));
                }
            }
        }

        throw $lastException;
    }

    /**
     * Set execution timeout
     */
    private function setTimeout(int $seconds): void
    {
        set_time_limit($seconds);
        // Additional timeout handling can be added here
    }

    /**
     * Clear execution timeout
     */
    private function clearTimeout(): void
    {
        set_time_limit(0);
    }

    /**
     * Create standardized error response
     */
    private function createErrorResponse(string $message): array
    {
        return [
            'success' => false,
            'error' => $message,
            'timestamp' => date('c'),
        ];
    }
}
