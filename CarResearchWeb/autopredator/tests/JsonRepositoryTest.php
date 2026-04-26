<?php
declare(strict_types=1);

use App\Data\DetailRepository;
use App\Data\JsonLoader;
use App\Repositories\JsonCarRepository;
use PHPUnit\Framework\TestCase;

final class JsonRepositoryTest extends TestCase
{
    private function repo(): JsonCarRepository
    {
        return new JsonCarRepository(DATA_DIR);
    }

    public function testRepositoryLoadsBrands(): void
    {
        $brands = $this->repo()->getBrands();

        self::assertNotEmpty($brands, 'Expected brands to be loaded from the JSON dataset');
    }

    public function testBmwHasMultipleModels(): void
    {
        $models = $this->repo()->getModelsByMake('BMW');

        self::assertGreaterThan(1, count($models), 'BMW should have multiple models available');
    }

    public function testInvalidJsonIsHandledGracefully(): void
    {
        $tempDir = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'autopredator-tests';
        @mkdir($tempDir, 0777, true);

        $badFile = $tempDir . DIRECTORY_SEPARATOR . 'bad.json';
        file_put_contents($badFile, '{invalid-json');

        $loader = new JsonLoader($tempDir);
        $data = $loader->load('bad.json');

        self::assertSame([], $data, 'Invalid JSON should return an empty array instead of throwing');
    }

    public function testSlugTraversalIsRejected(): void
    {
        $detailRepo = new DetailRepository(new JsonLoader(DATA_DIR));

        self::assertNull($detailRepo->getDetailsBySlug('../new_carset'), 'Traversal attempts should return null');
        self::assertNotNull($detailRepo->getDetailsBySlug('xuv700'), 'Valid slug should resolve to details');
    }
}
