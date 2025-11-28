<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/car_repository.php';

$manufacturerId = (int) ($_GET['manufacturer_id'] ?? 0);
$manufacturer = $manufacturerId > 0 ? get_manufacturer_by_id($manufacturerId) : null;
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

$families = get_model_families_by_manufacturer($manufacturerId);
?>

<section class="breadcrumb-nav">
    <div class="container">
        <a href="index.php">Home</a> / <span><?= e($manufacturer['name']) ?></span>
    </div>
</section>

<section class="hero hero-small">
    <div class="container">
        <h1><?= e($manufacturer['name']) ?> – All Models</h1>
        <p>Explore every model from <?= e($manufacturer['name']) ?> with detailed specs and pricing.</p>
    </div>
</section>

<div class="container">
    <section class="section">
        <div class="section-header">
            <h2>Model Families</h2>
            <p><?= count($families) ?> model families available</p>
        </div>

        <?php if (empty($families)): ?>
            <div class="empty-state">
                <p>No models found for this manufacturer.</p>
            </div>
        <?php else: ?>
            <div class="grid grid-responsive">
                <?php foreach ($families as $family): ?>
                    <article class="card model-card">
                        <div class="card-header">
                            <h3><?= e($family['nameplate']) ?></h3>
                            <span class="badge badge-info"><?= e($family['body_type'] ?? 'Car') ?></span>
                        </div>
                        <div class="card-body">
                            <?php if (!empty($family['segment'])): ?>
                                <p class="small">Segment: <?= e($family['segment']) ?></p>
                            <?php endif; ?>
                            <?php if (!empty($family['fuel_scope'])): ?>
                                <p class="small">Fuel: <?= e($family['fuel_scope']) ?></p>
                            <?php endif; ?>
                        </div>
                        <div class="card-footer">
                            <a href="model.php?family_id=<?= (int) $family['id'] ?>" class="btn btn-primary">View Models</a>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </section>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
