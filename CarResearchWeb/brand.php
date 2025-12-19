<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/repository.php';

$manufacturerId = (int) ($_GET['manufacturer_id'] ?? 0);
$manufacturerName = trim($_GET['manufacturer_name'] ?? '');
$manufacturer = car_service()->findBrandByIdOrName($manufacturerId, $manufacturerName);

$page_title = $manufacturer ? ($manufacturer['name'] . ' Cars & Models | Autopredator') : 'Manufacturers | Autopredator';
$page_description = $manufacturer
    ? 'Browse all ' . e($manufacturer['name']) . ' vehicles, compare models and find the best car for your budget.'
    : 'Browse all active manufacturers on Autopredator.';

if ($manufacturer === null && $manufacturerId > 0) {
    redirect('brand.php');
}

if ($manufacturer === null) {
    $manufacturers = get_all_manufacturers();
    ?>
    <section class="breadcrumb-nav">
        <div class="container">
            <a href="index.php">Home</a> / <span>Manufacturers</span>
        </div>
    </section>

    <section class="hero hero-small">
        <div class="container">
            <h1>All Manufacturers</h1>
            <p>Select a brand to explore model families and variants.</p>
        </div>
    </section>

    <div class="container">
        <section class="section">
            <div class="grid grid-responsive">
                <?php foreach ($manufacturers as $man): ?>
                    <article class="card model-card">
                        <div class="card-image">
                            <img src="assets/img/placeholder-brand.png" alt="<?= e($man['name']) ?> logo" loading="lazy">
                        </div>
                        <div class="card-header">
                            <h3><?= e($man['name']) ?></h3>
                            <?php if (!empty($man['country'])): ?>
                                <span class="badge badge-info"><?= e($man['country']) ?></span>
                            <?php endif; ?>
                        </div>
                        <?php if (!empty($man['description'])): ?>
                            <div class="card-body">
                                <p class="small"><?= e(truncate($man['description'], 120)) ?></p>
                            </div>
                        <?php endif; ?>
                        <div class="card-footer">
                            <a href="brand.php?manufacturer_id=<?= (int) $man['id'] ?>" class="btn btn-primary">View Models</a>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        </section>
    </div>
    <?php
    require_once __DIR__ . '/includes/footer.php';
    exit;
}

$models = car_service()->getModelsByBrand($manufacturer['name']);
$modelCount = count($models);
?>

<section class="breadcrumb-nav">
    <div class="container">
        <a href="index.php">Home</a> / <span><?= e($manufacturer['name']) ?></span>
    </div>
</section>

<section class="hero hero-small">
    <div class="container">
        <h1><?= e($manufacturer['name']) ?> — All Models</h1>
        <p>Explore every model from <?= e($manufacturer['name']) ?> with detailed specs and pricing.</p>
    </div>
</section>

<div class="container">
    <section class="section">
        <div class="section-header">
            <h2>Models</h2>
            <p>Found <?= $modelCount ?> models</p>
        </div>

        <?php if (empty($models)): ?>
            <div class="empty-state">
                <p>No models found for this manufacturer.</p>
            </div>
        <?php else: ?>
            <div class="grid grid-responsive">
                <?php foreach ($models as $model): ?>
                    <article class="card model-card">
                        <div class="card-header">
                            <h3><?= e($model['model'] ?? $model['name'] ?? '') ?></h3>
                            <span class="badge badge-info"><?= display_value($model['segment'] ?? null) ?></span>
                        </div>
                        <div class="card-body">
                            <p class="small">Launch Year: <?= display_value($model['launch_year'] ?? null) ?></p>
                            <p class="small">Fuel: <?= !empty($model['fuel_types']) ? e(implode(', ', (array) $model['fuel_types'])) : '—' ?></p>
                            <?php if (!empty($model['price_range'])): ?>
                                <p class="small">
                                    Price:
                                    <?= format_price((float) ($model['price_range']['min'] ?? 0)) ?>
                                    -
                                    <?= format_price((float) ($model['price_range']['max'] ?? 0)) ?>
                                </p>
                            <?php else: ?>
                                <p class="small">Price: —</p>
                            <?php endif; ?>
                        </div>
                        <div class="card-footer">
                            <a href="model.php?model_name=<?= urlencode($model['model'] ?? $model['name']) ?>" class="btn btn-primary">View Variants</a>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </section>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
