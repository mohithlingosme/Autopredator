<?php
declare(strict_types=1);

namespace App\AI\Chains;

/**
 * Minimal contract for AI chains.
 */
interface Chain
{
    /**
     * @param array<string, mixed> $input
     * @return array<string, mixed>
     */
    public function run(array $input): array;
}
