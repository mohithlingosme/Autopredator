<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/search_helpers.php';
require_once __DIR__ . '/includes/repository.php';

$filters = build_search_filters($_GET);
$results = search_cars($filters);
$total = search_cars_count($filters);
$totalPages = (int) max(1, ceil($total / $filters['limit']));
$page = $filters['page'];
$manufacturers = get_all_manufacturers();

function checked_in(string $value, array $haystack): bool
{
    return in_array($value, $haystack, true);
}
?>

<section class="section container">
    <div class="result-meta">
        <h1>Search Results<?= $filters['search_text'] ? ': ' . e($filters['search_text']) : '' ?></h1>
        <button class="btn btn-outline" data-filter-toggle type="button">Filters</button>
    </div>
    <div class="grid grid-2 search-layout">
        <aside class="filters" data-filter-panel>
            <h3>Filters</h3>
            <form action="/search.php" method="get" class="search-filter-form">
                <label>
                    Search
                    <input type="text" name="q" value="<?= e($filters['search_text']) ?>" placeholder="Brand or model">
                </label>

                <label>
                    Brand
                    <select name="manufacturer_id">
                        <option value="">All brands</option>
                        <?php foreach ($manufacturers as $man): ?>
                            <option value="<?= (int) $man['id'] ?>" <?= $filters['manufacturer_id'] === (int) $man['id'] ? 'selected' : '' ?>>
                                <?= e($man['name']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </label>

                <div class="filter-group">
                    <div class="filter-group-title">Body Type</div>
                    <?php foreach (['Hatchback','Sedan','SUV','MUV','Coupe','Convertible'] as $type): ?>
                        <label class="checkbox">
                            <input type="checkbox" name="body_type[]" value="<?= e($type) ?>" <?= checked_in($type, $filters['body_type']) ? 'checked' : '' ?>>
                            <?= e($type) ?>
                        </label>
                    <?php endforeach; ?>
                </div>

                <div class="filter-group">
                    <div class="filter-group-title">Fuel Type</div>
                    <?php foreach (['Petrol','Diesel','CNG','Electric','Hybrid'] as $fuel): ?>
                        <label class="checkbox">
                            <input type="checkbox" name="fuel_type[]" value="<?= e($fuel) ?>" <?= checked_in($fuel, $filters['fuel_type']) ? 'checked' : '' ?>>
                            <?= e($fuel) ?>
                        </label>
                    <?php endforeach; ?>
                </div>

                <div class="filter-group">
                    <div class="filter-group-title">Transmission</div>
                    <?php foreach (['MT','AT','AMT','CVT','DCT'] as $trans): ?>
                        <label class="checkbox">
                            <input type="checkbox" name="transmission[]" value="<?= e($trans) ?>" <?= checked_in($trans, $filters['transmission']) ? 'checked' : '' ?>>
                            <?= e($trans) ?>
                        </label>
                    <?php endforeach; ?>
                </div>

                <label>
                    Seating
                    <select name="seats">
                        <option value="">Any</option>
                        <?php foreach ([4,5,6,7,8] as $seat): ?>
                            <option value="<?= $seat ?>" <?= $filters['seats'] === $seat ? 'selected' : '' ?>><?= $seat ?>+</option>
                        <?php endforeach; ?>
                    </select>
                </label>

                <div class="input-row">
                    <input type="number" name="min_budget" placeholder="Min Rs." value="<?= e((string) ($filters['min_budget'] ?? '')) ?>">
                    <input type="number" name="max_budget" placeholder="Max Rs." value="<?= e((string) ($filters['max_budget'] ?? '')) ?>">
                </div>

                <div class="filter-actions">
                    <button class="btn btn-primary" type="submit">Apply filters</button>
                    <a class="btn btn-outline" href="search.php">Clear filters</a>
                </div>
            </form>
        </aside>

        <div class="grid" style="gap: 1rem;">
            <?php if (empty($results)): ?>
                <article class="card empty-state">
                    <h3>No cars match these filters</h3>
                    <p>We couldn’t find results<?= $filters['search_text'] ? ' for "' . e($filters['search_text']) . '"' : '' ?>. Try clearing filters or widening the budget range.</p>
                    <div class="badge-row">
                        <?php if ($filters['manufacturer_id']): ?>
                            <span class="badge badge-info">Brand selected</span>
                        <?php endif; ?>
                        <?php if (!empty($filters['body_type'])): ?>
                            <span class="badge badge-success">Body: <?= e(implode(', ', $filters['body_type'])) ?></span>
                        <?php endif; ?>
                        <?php if (!empty($filters['fuel_type'])): ?>
                            <span class="badge badge-warning">Fuel: <?= e(implode(', ', $filters['fuel_type'])) ?></span>
                        <?php endif; ?>
                    </div>
                    <div class="actions">
                        <a class="btn btn-primary" href="search.php">Reset filters</a>
                        <a class="btn btn-outline" href="index.php">Back to home</a>
                    </div>
                </article>
            <?php endif; ?>

            <?php foreach ($results as $row): ?>
                <article class="card result-card">
                    <div class="meta">
                        <h3><?= e($row['manufacturer_name']) ?> <?= e($row['family_nameplate']) ?> <?= e($row['variant_name']) ?></h3>
                        <div class="badge-row">
                            <?php if (!empty($row['body_type'])): ?>
                                <span class="badge badge-info"><?= e($row['body_type']) ?></span>
                            <?php endif; ?>
                            <?php if (!empty($row['fuel_type'])): ?>
                                <span class="badge badge-success"><?= e($row['fuel_type']) ?></span>
                            <?php endif; ?>
                            <?php if (!empty($row['transmission'])): ?>
                                <span class="badge badge-warning"><?= e($row['transmission']) ?></span>
                            <?php endif; ?>
                        </div>
                        <?php if (isset($row['ex_showroom_price'])): ?>
                            <div class="price"><?= format_price((float) $row['ex_showroom_price']) ?></div>
                        <?php endif; ?>
                    </div>
                    <div class="actions">
                        <a class="btn btn-outline btn-compare-toggle" href="compare.php?ids=<?= (int) $row['variant_id'] ?>">Add to Compare</a>
                        <a class="btn btn-primary" href="variant.php?variant_id=<?= (int) $row['variant_id'] ?>">View Variant</a>
                    </div>
                </article>
            <?php endforeach; ?>

            <div class="result-meta">
                <?php $prev = max(1, $page - 1); $next = min($totalPages, $page + 1); ?>
                <a class="btn btn-outline" href="<?= '/search.php?' . e(http_build_query(array_merge($_GET, ['page' => $prev]))) ?>">Previous</a>
                <span>Page <?= $page ?> / <?= $totalPages ?></span>
                <a class="btn btn-outline" href="<?= '/search.php?' . e(http_build_query(array_merge($_GET, ['page' => $next]))) ?>">Next</a>
            </div>
        </div>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
