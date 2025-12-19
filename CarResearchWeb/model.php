<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/repository.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$modelName = trim($_GET['model_name'] ?? '');
if ($modelName === '') {
    redirect('index.php');
}

$model = car_service()->getModel($modelName);
if ($model === null) {
    redirect('index.php');
}

$manufacturer = get_manufacturer_by_name($model['make']);
$manufacturerId = $manufacturer['id'] ?? 0;
$variants = car_service()->getVariantsByModel($modelName);
$familyModels = car_service()->getModelsByBrand($model['make']);
$page_title = $model['model'] . ' Models & Variants | Autopredator';
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
                    <h2>Variants</h2>
                    <p class="muted"><?= count($variants) ?> variants available</p>
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
                                        <th>Fuel</th>
                                        <th>Transmission</th>
                                        <th>Price</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($variants as $index => $variant): ?>
                                        <?php $variantId = $index + 1; ?>
                                        <tr>
                                            <td><?= e($variant['name'] ?? '') ?></td>
                                            <td><?= e(display_value($variant['fuel_type'] ?? null)) ?></td>
                                            <td><?= e(display_value($variant['transmission'] ?? null)) ?></td>
                                            <td class="price">
                                                <?php if (!empty($variant['price_numeric'])): ?>
                                                    <?= format_price((float) $variant['price_numeric']) ?>
                                                <?php else: ?>
                                                    Price on request
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <a href="variant.php?variant_id=<?= (int) $variantId ?>&model_name=<?= urlencode($model['model']) ?>" class="btn btn-outline btn-sm">View</a>
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
