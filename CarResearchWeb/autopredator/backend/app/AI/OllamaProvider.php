<?php
declare(strict_types=1);

namespace App\AI;

use App\AI\ProviderInterface;

/**
 * Ollama Local LLM Provider
 *
 * Integrates local Ollama server (llama3.2:3b) for automotive data enrichment.
 * Supports structured JSON outputs for KG enhancement.
 */
class OllamaProvider implements ProviderInterface
{
    private string $baseUrl = 'http://localhost:11434';
    private string $model = 'llama3.2:3b';
    
    public function generateText(string $prompt, array $options = []): string
    {
        $payload = [
            'model' => $this->model,
            'prompt' => $this->buildPrompt($prompt, $options),
            'stream' => false,
            'options' => [
                'temperature' => $options['temperature'] ?? 0.3,
                'top_p' => 0.9,
            ]
        ];

        $response = $this->post('/api/generate', $payload);
        return $response['response'] ?? 'Error: No response from Ollama';
    }

    public function generateJson(string $prompt, array $options = []): array
    {
        $system = "You are an automotive data expert. Respond ONLY with valid JSON. Never use markdown or explanations.";
        $payload = [
            'model' => $this->model,
            'prompt' => $system . "\n\n" . $prompt,
            'stream' => false,
            'format' => 'json',
            'options' => [
                'temperature' => $options['temperature'] ?? 0.1,
            ]
        ];

        $response = $this->post('/api/generate', $payload);
        $jsonStr = $response['response'] ?? '{}';
        return json_decode($jsonStr, true) ?: ['error' => 'Invalid JSON from Ollama'];
    }

    private function buildPrompt(string $prompt, array $options): string
    {
        $context = $options['context'] ?? '';
        return trim("Context: {$context}\n\nQuery: {$prompt}\n\nResponse:");
    }

    private function post(string $endpoint, array $payload): array
    {
        $ch = curl_init($this->baseUrl . $endpoint);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_TIMEOUT => 120
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            error_log("Ollama error: HTTP $httpCode - $response");
            return ['error' => 'Ollama unavailable'];
        }

        return json_decode($response, true) ?: [];
    }

    public function getProviderName(): string
    {
        return 'ollama';
    }

    public function isAvailable(): bool
    {
        $test = $this->post('/api/tags', []);
        return isset($test['models']);
    }
}

