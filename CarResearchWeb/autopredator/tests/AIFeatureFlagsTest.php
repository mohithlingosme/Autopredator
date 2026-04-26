<?php
declare(strict_types=1);

use App\AI\Tools\FeatureFlags;
use PHPUnit\Framework\TestCase;

final class AIFeatureFlagsTest extends TestCase
{
    public function testFeatureFlagsReflectGlobalConstants(): void
    {
        $flags = FeatureFlags::current();

        self::assertArrayHasKey('AI_ENABLED', $flags);
        self::assertSame(AI_ENABLED, $flags['AI_ENABLED']);
        self::assertArrayHasKey('AI_CONTENT_ENABLED', $flags);
        self::assertSame(AI_CONTENT_ENABLED, $flags['AI_CONTENT_ENABLED']);
        self::assertArrayHasKey('AI_SUPPORT_ENABLED', $flags);
        self::assertSame(AI_SUPPORT_ENABLED, $flags['AI_SUPPORT_ENABLED']);
    }
}
