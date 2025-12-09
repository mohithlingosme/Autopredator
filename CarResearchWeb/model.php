<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';

if ($USE_JSON) {
    require_once __DIR__ . '/includes/json_car_repository.php';
} else {
    require_once __DIR__ . '/includes/car_repository.php';
}

$modelName = trim($_GET['model_name'] ?? '');
$modelId = (int) ($_GET['model_id'] ?? 0);

if ($USE_JSON) {
    if (empty($modelName)) {
        redirect('index.php');
    }
    $model = [
        'name' => $modelName,
        'manufacturer_name' => '', // Will be set from variants
        'segment' => '',
        'launch_year' => 2023,
        'body_type' => 'Car',
        'fuel_scope' => 'All'
    ];
    $variants = json_get_variants_by_model($modelName);
    if (!empty($variants)) {
        $model['manufacturer_name'] = $variants[0]['brand'];
        $model['segment'] = $variants[0]['segment'];
    }
    $familyModels = []; // Not applicable in JSON mode
} else {
    $familyId = (int) ($_GET['family_id'] ?? 0);

    if ($familyId > 0 && $modelId === 0) {
        $models = get_models_by_family($familyId);
        if ($models === []) {
            redirect('index.php');
        }
        $modelId = (int) $models[0]['id'];
    }

    $model = $modelId > 0 ? get_model_by_id($modelId) : null;
    if ($model === null) {
        redirect('index.php');
    }

    $variants = get_variants_by_model($modelId);
    $familyModels = get_models_by_family((int) $model['family_id']);
}
$page_title = $model['name'] . ' Models & Variants | Autopredator';
?>

<section class="breadcrumb-nav">
    <div class="container">
        <a href="index.php">Home</a> /
        <a href="brand.php?manufacturer_id=<?= (int) $model['manufacturer_id'] ?>"><?= e($model['manufacturer_name']) ?></a> /
        <span><?= e($model['name']) ?></span>
    </div>
</section>

<section class="hero hero-small">
    <div class="container">
        <h1><?= e($model['name']) ?> Models & Variants</h1>
        <p>Explore all available variants, specs and pricing for <?= e($model['name']) ?>.</p>
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
                                <a href="model.php?model_id=<?= (int) $m['id'] ?>"
                                   class="<?= (int) $m['id'] === $modelId ? 'active' : '' ?>">
                                    <?= e($m['name']) ?>
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
                    <h2><?= e($model['name']) ?></h2>
                    <div class="model-info">
                        <p><strong>Launch Year:</strong> <?= e((string) ($model['launch_year'] ?? '')) ?></p>
                        <?php if (!empty($model['body_type'])): ?>
                            <p><strong>Body Type:</strong> <?= e($model['body_type']) ?></p>
                        <?php endif; ?>
                        <?php if (!empty($model['segment'])): ?>
                            <p><strong>Segment:</strong> <?= e($model['segment']) ?></p>
                        <?php endif; ?>
                        <?php if (!empty($model['fuel_scope'])): ?>
                            <p><strong>Fuel Scope:</strong> <?= e($model['fuel_scope']) ?></p>
                        <?php endif; ?>
                    </div>
                    <?php if (!empty($model['description'])): ?>
                        <p class="small"><?= e($model['description']) ?></p>
                    <?php endif; ?>
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
                                    <?php foreach ($variants as $variant): ?>
                                        <tr>
                                            <td>
                                                <div class="variant-name">
                                                    <img src="assets/img/placeholder-car.png" alt="<?= e($variant['variant_name']) ?>" class="variant-thumb" loading="lazy">
                                                    <?= e($variant['variant_name']) ?>
                                                </div>
                                            </td>
                                            <td>
                                                <?php if (!empty($variant['fuel_type'])): ?>
                                                    <span class="badge badge-info"><?= e($variant['fuel_type']) ?></span>
                                                <?php endif; ?>
                                            </td>
                                            <td><?= e($variant['transmission'] ?? 'MT') ?></td>
                                            <td class="price">
                                                <?php if (!empty($variant['ex_showroom_price'])): ?>
                                                    <?= format_price((float) $variant['ex_showroom_price']) ?>
                                                <?php else: ?>
                                                    Price on request
                                                <?php endif; ?>
                                            </td>
                                            <td class="table-actions">
                                                <a href="variant.php?variant_id=<?= (int) $variant['id'] ?>" class="btn btn-sm btn-primary">
                                                    View Details
                                                </a>
                                                <button class="btn btn-sm btn-outline compare-toggle" data-variant-id="<?= (int) $variant['id'] ?>">
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
