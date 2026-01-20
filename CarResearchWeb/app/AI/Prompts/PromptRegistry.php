<?php
declare(strict_types=1);

namespace App\AI\Prompts;

use App\AI\OutputRules;

/**
 * In-code prompt registry with versioned templates.
 */
final class PromptRegistry
{
    /**
     * @return PromptTemplate[]
     */
    public static function all(): array
    {
        return array_values(self::templates());
    }

    public static function get(string $id): ?PromptTemplate
    {
        $templates = self::templates();
        return $templates[$id] ?? null;
    }

    /**
     * @return array<string, PromptTemplate>
     */
    private static function templates(): array
    {
        $rules = self::formatOutputRules();

        return [
            'content_draft_v1' => new PromptTemplate(
                'content_draft_v1',
                'v1',
                "You are the Autopredator content assistant focused on the Indian automotive market.\n{$rules}\nReturn markdown in draft status with outline and citation placeholders.",
                ['task' => 'content_draft']
            ),
            'data_enrichment_v1' => new PromptTemplate(
                'data_enrichment_v1',
                'v1',
                "You are the Autopredator data assistant. Provide JSON patch suggestions for vehicle variants.\n{$rules}\nNever write directly to storage; only suggest deltas with confidence.",
                ['task' => 'data_enrichment']
            ),
        ];
    }

    private static function formatOutputRules(): string
    {
        $lines = [];
        foreach (OutputRules::descriptions() as $rule => $description) {
            $lines[] = "- {$rule}: {$description}";
        }

        return "Follow these output rules:\n" . implode("\n", $lines);
    }
}
