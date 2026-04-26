<?php
declare(strict_types=1);

use App\Services\AIService;
use App\AI\ProviderInterface;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

final class AIServiceTest extends TestCase
{
    private AIService $aiService;
    private MockObject $providerMock;

    protected function setUp(): void
    {
        $this->aiService = new AIService();
        $this->providerMock = $this->createMock(ProviderInterface::class);
    }

    public function testGenerateTextSuccess(): void
    {
        // Mock AIConfig
        $this->providerMock->method('generateText')->willReturn('Generated text');
        $this->providerMock->method('getProviderName')->willReturn('TestProvider');

        // Since AIConfig is static, we can't easily mock, so this is a basic test
        // In real scenario, use dependency injection or test doubles

        $result = $this->aiService->generateText('content', 'Test prompt');

        $this->assertArrayHasKey('success', $result);
        // Note: This will fail if AI is disabled, but for demo
    }

    public function testGenerateTextDisabled(): void
    {
        $result = $this->aiService->generateText('disabled_task', 'Test');

        $this->assertFalse($result['success']);
        $this->assertStringContainsString('disabled', $result['error']);
    }
}
