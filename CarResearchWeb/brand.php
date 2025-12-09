<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';

if ($USE_JSON) {
    require_once __DIR__ . '/includes/json_car_repository.php';
} else {
    require_once __DIR__ . '/includes/car_repository.php';
}

$manufacturerId = (int) ($_GET['manufacturer_id'] ?? 0);
$manufacturerName = trim($_GET['manufacturer_name'] ?? '');
$manufacturer = null;

if ($manufacturerId > 0 && !$USE_JSON) {
    $manufacturer = get_manufacturer_by_id($manufacturerId);
} elseif ($manufacturerName !== '' && $USE_JSON) {
    // For JSON mode, create a fake manufacturer object
    $manufacturer = [
        'id' => 1, // Placeholder
        'name' => $manufacturerName,
        'country' => 'Germany', // Default
        'description' => null
    ];
} elseif ($manufacturerId > 0 && $USE_JSON) {
    // Fallback: try to get manufacturer name from brands list
    $brands = json_get_brands();
    foreach ($brands as $brand) {
        if ($brand['id'] == $manufacturerId) {
            $manufacturer = [
                'id' => $brand['id'],
                'name' => $brand['name'],
                'country' => $brand['country'] ?? 'India',
                'description' => null
            ];
            break;
        }
    }
}
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

if ($USE_JSON) {
    $models = json_get_models_by_brand($manufacturer['name']);
} else {
    $families = get_model_families_by_manufacturer($manufacturerId);
    $models = [];
    foreach ($families as $family) {
        $familyModels = get_models_by_family($family['id']);
        $models = array_merge($models, $familyModels);
    }
}
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
            <h2>Models</h2>
            <p><?= count($models) ?> models available</p>
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
                            <h3><?= e($model['name']) ?></h3>
                            <span class="badge badge-info"><?= e($model['segment'] ?? 'Car') ?></span>
                        </div>
                        <div class="card-body">
                            <?php if (!empty($model['launch_year'])): ?>
                                <p class="small">Launch Year: <?= e((string) $model['launch_year']) ?></p>
                            <?php endif; ?>
                            <?php if (!empty($model['fuel_types'])): ?>
                                <p class="small">Fuel: <?= e(implode(', ', $model['fuel_types'])) ?></p>
                            <?php endif; ?>
                            <?php if (!empty($model['price_range'])): ?>
                                <p class="small">Price: ₹<?= number_format($model['price_range']['min']) ?> - ₹<?= number_format($model['price_range']['max']) ?></p>
                            <?php endif; ?>
                        </div>
                        <div class="card-footer">
                            <?php if ($USE_JSON): ?>
                                <a href="model.php?model_name=<?= urlencode($model['name']) ?>" class="btn btn-primary">View Variants</a>
                            <?php else: ?>
                                <a href="model.php?model_id=<?= (int) $model['id'] ?>" class="btn btn-primary">View Variants</a>
                            <?php endif; ?>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </section>
</div>

<?php
require_once __DIR__ . '/includes/footer.php';
