<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/search_helpers.php';
require_once __DIR__ . '/includes/repository.php';
require_once __DIR__ . '/views/partials/filter_panel.php';
require_once __DIR__ . '/views/partials/pagination.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$filters = build_search_filters($_GET);
$results = search_cars($filters);
$total = search_cars_count($filters);
$totalPages = (int) max(1, ceil($total / $filters['limit']));
$page = $filters['page'];
$manufacturers = get_all_manufacturers();

// Options for filters
$fuelTypes = [];
foreach (car_service()->searchVariants(['limit' => 200, 'offset' => 0]) as $row) {
    $fuel = $row['fuel_type'] ?? '';
    if ($fuel !== '' && !in_array($fuel, $fuelTypes, true)) {
        $fuelTypes[] = $fuel;
    }
}

$bodyTypes = [];
foreach (car_service()->getFeaturedFamilies(50) as $fam) {
    $body = $fam['body_type'] ?? '';
    if ($body !== '' && !in_array($body, $bodyTypes, true)) {
        $bodyTypes[] = $body;
    }
}
?>

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft">Search</p>
            <h1>Find the right car</h1>
            <p>Filter by price, body type, fuel, and more. Persisted query params keep your back button happy.</p>
            <?php include __DIR__ . '/views/partials/search_bar.php'; ?>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="filter-shell">
            <form method="get" class="filter-panel" data-filter-panel>
                <?php render_filter_panel($filters, ['fuel_types' => $fuelTypes, 'body_types' => $bodyTypes, 'manufacturers' => $manufacturers]); ?>
            </form>

            <main>
                <div class="section-header">
                    <div>
                        <p class="muted">Search Results</p>
                        <h2><?php if (!empty($_GET['q'])): ?><?= e((string) $total) ?> results for "<?= e($_GET['q']) ?>"<?php else: ?><?= e((string) $total) ?> cars<?php endif; ?></h2>
                    </div>
                    <div class="card" style="padding:12px; display:flex; gap:8px; align-items:center;">
                        <label class="muted" for="sort-by">Sort</label>
                        <select id="sort-by" onchange="location.href='search.php?<?= http_build_query(array_merge($_GET, ['sort_by' => ''])) ?>&sort_by='+this.value">
                            <option value="price_asc" <?= ($filters['sort_by'] ?? '') === 'price_asc' ? 'selected' : '' ?>>Price (low to high)</option>
                            <option value="price_desc" <?= ($filters['sort_by'] ?? '') === 'price_desc' ? 'selected' : '' ?>>Price (high to low)</option>
                            <option value="mileage_desc" <?= ($filters['sort_by'] ?? '') === 'mileage_desc' ? 'selected' : '' ?>>Mileage (high to low)</option>
                            <option value="power_desc" <?= ($filters['sort_by'] ?? '') === 'power_desc' ? 'selected' : '' ?>>Power (high to low)</option>
                        </select>
                        <button class="btn btn-outline" type="button" data-filter-toggle>Filters</button>
                    </div>
                </div>

                <?php if (!empty($filters) && array_filter($filters, fn($v) => $v !== '' && $v !== 0)): ?>
                    <div class="chip-row">
                        <?php if (!empty($filters['budget_min']) || !empty($filters['budget_max'])): ?>
                            <span class="chip">Budget: ₹<?= $filters['budget_min'] ?: '0' ?> - ₹<?= $filters['budget_max'] ?: '∞' ?> <button onclick="removeFilter('budget_min')">×</button></span>
                        <?php endif; ?>
                        <?php if (!empty($filters['fuel_type'])): ?>
                            <span class="chip">Fuel: <?= e($filters['fuel_type']) ?> <button onclick="removeFilter('fuel_type')">×</button></span>
                        <?php endif; ?>
                        <?php if (!empty($filters['transmission'])): ?>
                            <span class="chip">Transmission: <?= e($filters['transmission']) ?> <button onclick="removeFilter('transmission')">×</button></span>
                        <?php endif; ?>
                        <?php if (!empty($filters['body_type'])): ?>
                            <span class="chip">Body: <?= e($filters['body_type']) ?> <button onclick="removeFilter('body_type')">×</button></span>
                        <?php endif; ?>
                    </div>
                <?php endif; ?>

                <?php if (empty($results)): ?>
                    <?php render_empty_state('No results', 'Adjust filters or try another keyword.'); ?>
                <?php else: ?>
                    <div class="result-grid">
                        <?php foreach ($results as $row): ?>
                            <article class="card">
                                <p class="muted"><?= e($row['manufacturer_name']) ?></p>
                                <h3><?= e($row['model_name']) ?></h3>
                                <p class="muted"><?= e($row['variant_name'] ?? $row['variant'] ?? '') ?></p>
                                <div class="badge-row">
                                    <?php if (!empty($row['body_type'])): ?><span class="badge badge-soft"><?= e($row['body_type']) ?></span><?php endif; ?>
                                    <?php if (!empty($row['fuel_type'])): ?><span class="badge badge-success"><?= e($row['fuel_type']) ?></span><?php endif; ?>
                                    <?php if (!empty($row['transmission'])): ?><span class="badge badge-warning"><?= e($row['transmission']) ?></span><?php endif; ?>
                                </div>
                                <?php if (!empty($row['ex_showroom_price'])): ?>
                                    <p class="muted">Price</p>
                                    <p class="price"><?= format_price((float) $row['ex_showroom_price']) ?></p>
                                <?php endif; ?>
                                <div class="card-footer">
                                    <a class="btn btn-primary" href="variant.php?variant_id=<?= (int) ($row['variant_id'] ?? 0) ?>">View Variant</a>
                                    <button class="btn btn-outline btn-sm" type="button" data-compare-add="<?= e($row['model_name']) ?>" data-compare-label="<?= e($row['manufacturer_name'] . ' ' . $row['model_name']) ?>">Add to Compare</button>
                                </div>
                            </article>
                        <?php endforeach; ?>
                    </div>
                    <div style="margin-top:16px;">
                        <?php render_pagination($page, $totalPages, $_GET); ?>
                    </div>
                <?php endif; ?>
            </main>
        </div>
    </div>
</section>

<script>
function clearFilters() {
    location.href = 'search.php?q=<?= urlencode($_GET['q'] ?? '') ?>';
}

function removeFilter(filter) {
    const url = new URL(location.href);
    url.searchParams.delete(filter);
    if (filter === 'budget_min' || filter === 'budget_max') {
        url.searchParams.delete('budget_min');
        url.searchParams.delete('budget_max');
    }
    location.href = url.toString();
}
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
