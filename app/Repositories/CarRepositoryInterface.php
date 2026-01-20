<?php
declare(strict_types=1);

namespace App\Repositories;

/**
 * Contract for car data sources (JSON or database).
 */
interface CarRepositoryInterface
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function getBrands(): array;

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByMake(string $make): array;

    /**
     * @return array<string, mixed>|null
     */
    public function getModelByName(string $modelName): ?array;

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModel(string $modelName): array;

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function search(array $filters): array;

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantById(int $id): ?array;
}
