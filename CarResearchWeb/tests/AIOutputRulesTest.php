<?php
declare(strict_types=1);

use App\AI\OutputRules;
use PHPUnit\Framework\TestCase;

final class AIOutputRulesTest extends TestCase
{
    public function testRulesContainRequiredEntries(): void
    {
        $rules = OutputRules::all();

        self::assertContains(OutputRules::RULE_SUGGEST_ONLY, $rules);
        self::assertContains(OutputRules::RULE_HUMAN_APPROVAL, $rules);
        self::assertContains(OutputRules::RULE_CITATIONS_REQUIRED, $rules);
    }

    public function testRulesHaveDescriptions(): void
    {
        $descriptions = OutputRules::descriptions();

        foreach (OutputRules::all() as $rule) {
            self::assertArrayHasKey($rule, $descriptions);
            self::assertNotEmpty($descriptions[$rule]);
        }
    }
}
