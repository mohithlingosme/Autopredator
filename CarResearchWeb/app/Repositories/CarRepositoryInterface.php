<?php
declare(strict_types=1);

namespace App\Repositories;

/**
 * Minimal contract for car data sources (DB or JSON-backed).
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
     * @return array<int, array<string, mixed>>
     */
    public function getModelsByBrandSlug(string $brandSlug): array;

    /**
     * @return array<string, mixed>|null
     */
    public function getModelByName(string $modelName): ?array;

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModel(string $modelName): array;

    /**
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModelSlug(string $modelSlug): array;

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function search(array $filters): array;

    /**
     * @param array<string, mixed> $filters
     * @return array<int, array<string, mixed>>
     */
    public function searchVariants(array $filters): array;

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantById(int $id): ?array;

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantBySlug(string $slug): ?array;

    /**
     * @return array<string, mixed>|null
     */
    public function getVariantByKey(string $variantKey): ?array;

    /**
     * @return array<string, mixed>
     */
    public function getSpecsForVariant(string $variantKey): array;
}
