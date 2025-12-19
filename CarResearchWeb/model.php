<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/repository.php';

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

<section class="breadcrumb-nav">
    <div class="container">
        <a href="index.php">Home</a> /
        <a href="brand.php?manufacturer_id=<?= (int) $manufacturerId ?>"><?= e($manufacturer['name'] ?? $model['make']) ?></a> /
        <span><?= e($model['model']) ?></span>
    </div>
</section>

<section class="hero hero-small">
    <div class="container">
        <h1><?= e($model['model']) ?> Models & Variants</h1>
        <p>Explore all available variants, specs and pricing for <?= e($model['model']) ?>.</p>
    </div>
</section>

<div class="container">
    <div class="grid-layout">
        <aside class="sidebar">
            <?php if (!empty($familyModels) && count($familyModels) > 1): ?>
                <div class="card">
                    <h3>Other Models</h3>
                    <ul class="model-list">
                        <?php foreach ($familyModels as $m): ?>
                            <li>
                                <a href="model.php?model_name=<?= urlencode($m['model']) ?>"
                                   class="<?= strtolower($m['model']) === strtolower($modelName) ? 'active' : '' ?>">
                                    <?= e($m['model']) ?>
                                </a>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endif; ?>
        </aside>

        <main class="main-content">
            <section class="section">
                <div class="card">
                    <h2><?= e($model['model']) ?></h2>
                    <div class="model-info">
                        <p><strong>Launch Year:</strong> <?= display_value($model['launch_year'] ?? null) ?></p>
                        <?php if (!empty($model['segment'])): ?>
                            <p><strong>Segment:</strong> <?= e($model['segment']) ?></p>
                        <?php endif; ?>
                        <?php if (!empty($model['fuel_types'])): ?>
                            <p><strong>Fuel Scope:</strong> <?= e(implode(', ', (array) $model['fuel_types'])) ?></p>
                        <?php endif; ?>
                    </div>
                </div>
            </section>

            <section class="section">
                <div class="section-header">
                    <h2>Variants</h2>
                    <p><?= count($variants) ?> variants available</p>
                </div>

                <?php if (empty($variants)): ?>
                    <div class="empty-state">
                        <p>No variants found for this model.</p>
                    </div>
                <?php else: ?>
                    <div class="card">
                        <div class="table-responsive">
                            <table class="table variants-table">
                                <thead>
                                    <tr>
                                        <th>Variant Name</th>
                                        <th>Fuel</th>
                                        <th>Transmission</th>
                                        <th>Price</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($variants as $index => $variant): ?>
                                        <?php $variantId = $index + 1; ?>
                                        <tr>
                                            <td>
                                                <div class="variant-name">
                                                    <img src="assets/img/placeholder-car.png" alt="<?= e($variant['name']) ?>" class="variant-thumb" loading="lazy">
                                                    <?= e($variant['name']) ?>
                                                </div>
                                            </td>
                                            <td>
                                                <?= display_value($variant['fuel_type'] ?? null) ?>
                                            </td>
                                            <td><?= display_value($variant['transmission'] ?? null) ?></td>
                                            <td class="price">
                                                <?php if (!empty($variant['price_numeric'])): ?>
                                                    <?= format_price((float) $variant['price_numeric']) ?>
                                                <?php else: ?>
                                                    Price on request
                                                <?php endif; ?>
                                            </td>
                                            <td class="table-actions">
                                                <a href="variant.php?variant_id=<?= (int) $variantId ?>&model_name=<?= urlencode($model['model']) ?>" class="btn btn-sm btn-primary">
                                                    View Details
                                                </a>
                                                <button class="btn btn-sm btn-outline compare-toggle" data-variant-id="<?= (int) $variantId ?>">
                                                    Compare
                                                </button>
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
