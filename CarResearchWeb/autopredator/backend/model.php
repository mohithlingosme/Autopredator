<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$brandSlug = trim($_GET['brandSlug'] ?? '');
$modelSlug = trim($_GET['modelSlug'] ?? '');

// For backward compatibility, also support old parameters
if (empty($brandSlug) || empty($modelSlug)) {
    $modelName = trim($_GET['model_name'] ?? '');
    if ($modelName === '') {
        redirect('index.php');
    }

    // Try to find by old parameters and redirect to slug-based URL
    $model = car_service()->getModel($modelName);
    if ($model === null) {
        redirect('index.php');
    }

    $manufacturer = get_manufacturer_by_name($model['make']);
    if ($manufacturer) {
        $redirectUrl = "model.php?brandSlug=" . urlencode($manufacturer['slug'] ?? $manufacturer['name']) . "&modelSlug=" . urlencode($model['slug'] ?? $model['model']);
        header("Location: $redirectUrl", true, 301);
        exit;
    }
} else {
    // Use new slug-based lookup
    require_once __DIR__ . '/app/Repositories/BrandRepository.php';
    require_once __DIR__ . '/app/Repositories/ModelRepository.php';
    require_once __DIR__ . '/app/Repositories/VariantRepository.php';

    $brandRepo = new BrandRepository();
    $modelRepo = new ModelRepository();
    $variantRepo = new VariantRepository();

    $manufacturer = $brandRepo->findBySlug($brandSlug);
    $model = $modelRepo->findBySlug($modelSlug);

    if (!$manufacturer || !$model) {
        redirect('index.php');
    }

    // Get data from DB
    $variants = $variantRepo->getVariantsByModelId((int) $model['id']);
    $familyModels = $brandRepo->getModelsByBrandId((int) $manufacturer['id']);
}

$page_title = ($model['name'] ?? $model['model']) . ' Models & Variants | Autopredator';

// Breadcrumbs
$breadcrumbs = [
    ['url' => 'index.php', 'label' => 'Home'],
    ['url' => 'brand.php', 'label' => 'Brands'],
    ['url' => 'brand.php?brandSlug=' . urlencode($manufacturer['slug'] ?? $manufacturer['name']), 'label' => $manufacturer['name']],
    ['url' => '', 'label' => $model['name'] ?? $model['model']],
];

// Sorting logic
$sortBy = $_GET['sort'] ?? 'price_asc';
usort($variants, function($a, $b) use ($sortBy) {
    switch ($sortBy) {
        case 'price_asc':
            return ($a['price_numeric'] ?? 0) <=> ($b['price_numeric'] ?? 0);
        case 'price_desc':
            return ($b['price_numeric'] ?? 0) <=> ($a['price_numeric'] ?? 0);
        case 'mileage_desc':
            return ($b['mileage_kmpl'] ?? 0) <=> ($a['mileage_kmpl'] ?? 0);
        case 'power_desc':
            return ($b['horsepower'] ?? 0) <=> ($a['horsepower'] ?? 0);
        default:
            return strcmp($a['name'] ?? '', $b['name'] ?? '');
    }
});

// Best Value logic: mid-price + best mileage + common transmission
$bestValueIndex = null;
if (count($variants) > 1) {
    $prices = array_filter(array_column($variants, 'price_numeric'), fn($p) => $p > 0);
    $mileages = array_filter(array_column($variants, 'mileage_kmpl'), fn($m) => $m > 0);

    if (!empty($prices) && !empty($mileages)) {
        $minPrice = min($prices);
        $maxPrice = max($prices);
        $midPrice = ($minPrice + $maxPrice) / 2;
        $maxMileage = max($mileages);
        $transmissions = array_count_values(array_column($variants, 'transmission'));
        $commonTransmission = array_keys($transmissions, max($transmissions))[0];

        $bestScore = -1;
        foreach ($variants as $index => $variant) {
            $price = $variant['price_numeric'] ?? 0;
            $mileage = $variant['mileage_kmpl'] ?? 0;
            $transmission = $variant['transmission'] ?? '';
            $priceScore = 1 - abs($price - $midPrice) / ($maxPrice - $minPrice);
            $mileageScore = $mileage / $maxMileage;
            $transmissionScore = ($transmission === $commonTransmission) ? 1 : 0;
            $score = $priceScore + $mileageScore + $transmissionScore;
            if ($score > $bestScore) {
                $bestScore = $score;
                $bestValueIndex = $index;
            }
        }
    }
}
?>

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft"><?= e($model['make']) ?></p>
            <h1><?= e($model['model']) ?></h1>
            <p>Complete overview of variants, pricing and specs.</p>
            <div class="pill-row">
                <?php if (!empty($model['segment'])): ?>
                    <span class="pill">Segment: <?= e($model['segment']) ?></span>
                <?php endif; ?>
                <?php if (!empty($model['fuel_types'])): ?>
                    <span class="pill">Fuel: <?= e(implode(', ', (array) $model['fuel_types'])) ?></span>
                <?php endif; ?>
                <span class="pill">Launch: <?= e(display_value($model['launch_year'] ?? null)) ?></span>
            </div>
        </div>
    </div>
</section>

<div class="container" style="padding: 0 0 32px;">
    <div class="filter-shell" style="grid-template-columns: 320px 1fr;">
        <aside class="sticky-summary">
            <p class="muted">Variants</p>
            <h3><?= e((string) count($variants)) ?> available</h3>
            <?php if (!empty($variants)): ?>
                <p class="muted">Price range</p>
                <?php
                $prices = array_column($variants, 'price_numeric');
                $min = $prices ? min($prices) : 0;
                $max = $prices ? max($prices) : 0;
                ?>
                <p><strong><?= format_price((float) $min) ?><?php if ($max && $max !== $min): ?> - <?= format_price((float) $max) ?><?php endif; ?></strong></p>
            <?php endif; ?>
            <button class="btn btn-primary" type="button" data-compare-add="<?= e($model['model']) ?>" data-compare-label="<?= e($model['make'] . ' ' . $model['model']) ?>">Add to Compare</button>
            <div style="margin-top:16px;">
                <p class="muted">Other models</p>
                <?php if (count($familyModels) <= 1): ?>
                    <p class="muted">No other models listed.</p>
                <?php else: ?>
                    <ul style="padding-left:16px;">
                        <?php foreach ($familyModels as $m): ?>
                            <li><a href="model.php?model_name=<?= urlencode($m['model']) ?>" class="muted"><?= e($m['model']) ?></a></li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
            </div>
        </aside>

        <main>
            <section class="section" style="padding-top:0;">
                <div class="card">
                    <h2>Key Specs</h2>
                    <div class="spec-grid">
                        <div class="spec-item">
                            <p class="muted">Launch Year</p>
                            <strong><?= e(display_value($model['launch_year'] ?? null)) ?></strong>
                        </div>
                        <div class="spec-item">
                            <p class="muted">Fuel Types</p>
                            <strong><?= e(implode(', ', (array) ($model['fuel_types'] ?? []))) ?></strong>
                        </div>
                        <div class="spec-item">
                            <p class="muted">Segment</p>
                            <strong><?= e(display_value($model['segment'] ?? null)) ?></strong>
                        </div>
                        <div class="spec-item">
                            <p class="muted">Variants</p>
                            <strong><?= e((string) count($variants)) ?></strong>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section" style="padding-top:16px;">
                <div class="section-header">
                    <div>
                        <h2>Variants</h2>
                        <p class="muted"><?= count($variants) ?> variants available</p>
                    </div>
                    <div class="card" style="padding:12px; display:flex; gap:8px; align-items:center;">
                        <label class="muted" for="sort-variants">Sort</label>
                        <select id="sort-variants" onchange="location.href='model.php?model_name=<?= urlencode($modelName) ?>&sort='+this.value" aria-label="Sort variants">
                            <option value="price_asc" <?= $sortBy === 'price_asc' ? 'selected' : '' ?>>Price (low to high)</option>
                            <option value="price_desc" <?= $sortBy === 'price_desc' ? 'selected' : '' ?>>Price (high to low)</option>
                            <option value="mileage_desc" <?= $sortBy === 'mileage_desc' ? 'selected' : '' ?>>Mileage (high to low)</option>
                            <option value="power_desc" <?= $sortBy === 'power_desc' ? 'selected' : '' ?>>Power (high to low)</option>
                        </select>
                    </div>
                </div>

                <?php if (empty($variants)): ?>
                    <?php render_empty_state('No variants found', 'We will add variants soon'); ?>
                <?php else: ?>
                    <div class="card">
                        <div class="table-responsive">
                            <table class="table variants-table">
                                <thead>
                                    <tr>
                                        <th>Variant</th>
                                        <th>Engine</th>
                                        <th>Transmission</th>
                                        <th>Mileage/Range</th>
                                        <th>Price</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($variants as $index => $variant): ?>
                                        <?php $variantId = $index + 1; ?>
                                        <tr>
                                            <td>
                                                <?= e($variant['name'] ?? '') ?>
                                                <?php if ($index === $bestValueIndex): ?>
                                                    <span class="badge badge-success">Best Value</span>
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <?php if (!empty($variant['engine'])): ?>
                                                    <?= e($variant['engine']) ?>
                                                <?php elseif (!empty($variant['horsepower'])): ?>
                                                    <?= e($variant['horsepower']) ?> bhp
                                                <?php else: ?>
                                                    —
                                                <?php endif; ?>
                                            </td>
                                            <td><?= e(display_value($variant['transmission'] ?? null)) ?></td>
                                            <td>
                                                <?php if (!empty($variant['mileage_kmpl'])): ?>
                                                    <?= e($variant['mileage_kmpl']) ?> kmpl
                                                <?php elseif (!empty($variant['range_km'])): ?>
                                                    <?= e($variant['range_km']) ?> km range
                                                <?php else: ?>
                                                    —
                                                <?php endif; ?>
                                            </td>
                                            <td class="price">
                                                <?php if (!empty($variant['price_numeric'])): ?>
                                                    <?= format_price((float) $variant['price_numeric']) ?>
                                                <?php else: ?>
                                                    Price on request
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <div style="display: flex; gap: 4px; flex-wrap: wrap;">
                                                    <a href="variant.php?variant_id=<?= (int) $variantId ?>&model_name=<?= urlencode($model['model']) ?>" class="btn btn-outline btn-sm">View</a>
                                                    <button class="btn btn-outline btn-sm" type="button" data-compare-add="<?= e($variant['name'] ?? '') ?>" data-compare-label="<?= e($model['make'] . ' ' . $model['model'] . ' ' . ($variant['name'] ?? '')) ?>">Compare</button>
                                                    <button class="btn btn-outline btn-sm" type="button" data-shortlist-add="<?= e($variant['name'] ?? '') ?>" data-shortlist-label="<?= e($model['make'] . ' ' . $model['model'] . ' ' . ($variant['name'] ?? '')) ?>">Shortlist</button>
                                                </div>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <?php endif; ?>
            </section>
        </main>
    </div>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
