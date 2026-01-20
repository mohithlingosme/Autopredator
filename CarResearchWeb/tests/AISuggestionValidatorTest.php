<?php
declare(strict_types=1);

use App\AI\Validators\SuggestionValidator;
use PHPUnit\Framework\TestCase;

final class AISuggestionValidatorTest extends TestCase
{
    public function testValidSuggestionPayloadPasses(): void
    {
        $validator = new SuggestionValidator();

        $result = $validator->validate([
            'suggestions' => ['Example suggestion'],
            'citations' => [],
        ]);

        self::assertTrue($result['valid']);
        self::assertSame([], $result['errors']);
    }

    public function testMissingSuggestionsFails(): void
    {
        $validator = new SuggestionValidator();

        $result = $validator->validate(['citations' => []]);

        self::assertFalse($result['valid']);
        self::assertNotEmpty($result['errors']);
    }

    public function testApplyStatusIsRejected(): void
    {
        $validator = new SuggestionValidator();

        $result = $validator->validate([
            'status' => 'apply',
            'suggestions' => ['Do not apply directly'],
        ]);

        self::assertFalse($result['valid']);
        self::assertStringContainsString('blocked', implode(' ', $result['errors']));
    }
}
