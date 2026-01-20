<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/db.php';

/**
 * Repository for model-related database operations.
 */
class ModelRepository
{
    /**
     * Find model by ID.
     *
     * @param int $id
     * @return array<string, mixed>|null
     */
    public function findById(int $id): ?array
    {
        return db_select_one('SELECT id, name, slug, brand_id, launch_year, created_at FROM models WHERE id = ?', [$id]);
    }

    /**
     * Find model by slug.
     *
     * @param string $slug
     * @return array<string, mixed>|null
     */
    public function findBySlug(string $slug): ?array
    {
        return db_select_one('SELECT id, name, slug, brand_id, launch_year, created_at FROM models WHERE slug = ?', [$slug]);
    }

    /**
     * Get variants for a model by model ID.
     *
     * @param int $modelId
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModelId(int $modelId): array
    {
        return db_select('
            SELECT v.id, v.name, v.slug, v.fuel_type, v.transmission_type, v.created_at
            FROM variants v
            WHERE v.model_id = ?
            ORDER BY v.name
        ', [$modelId]);
    }

    /**
     * Get variants for a model by model slug.
     *
     * @param string $modelSlug
     * @return array<int, array<string, mixed>>
     */
    public function getVariantsByModelSlug(string $modelSlug): array
    {
        return db_select('
            SELECT v.id, v.name, v.slug, v.fuel_type, v.transmission_type, v.created_at
            FROM variants v
            JOIN models m ON v.model_id = m.id
            WHERE m.slug = ?
            ORDER BY v.name
        ', [$modelSlug]);
    }
}
