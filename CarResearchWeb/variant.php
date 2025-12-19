<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/repository.php';

$variantId = (int) ($_GET['variant_id'] ?? 0);
$modelName = trim($_GET['model_name'] ?? '');
$variantNameParam = trim($_GET['variant'] ?? '');

$variant = null;

if ($variantId > 0) {
    $variant = get_variant_by_id($variantId);
} elseif ($modelName !== '' && $variantNameParam !== '') {
    $variants = car_service()->getVariantsByModel($modelName);
    foreach ($variants as $index => $v) {
        if (strcasecmp($v['name'], $variantNameParam) === 0) {
            $variant = [
                'id' => $index + 1,
                'variant_name' => $v['name'],
                'fuel_type' => $v['fuel_type'],
                'transmission' => $v['transmission'],
                'ex_showroom_price' => $v['price_numeric'],
                'model_name' => $modelName,
                'manufacturer_name' => $v['brand'] ?? '',
                'manufacturer_id' => 0,
                'model_id' => $index + 1,
                'body_type' => $v['segment'] ?? 'Car',
            ];
            break;
        }
    }
}

if ($variant === null) {
    redirect('index.php');
}

$variantId = (int) ($variant['id'] ?? $variantId);
$manufacturerId = (int) ($variant['manufacturer_id'] ?? 0);
$modelVariants = car_service()->getVariantsByModel($variant['model_name'] ?? $modelName);
$favorites = fav_get_list();
$isFavorite = in_array($variantId, $favorites, true);
$page_title = ($variant['variant_name'] ?? 'Variant') . ' - ' . ($variant['manufacturer_name'] ?? '') . ' | Autopredator';
?>

<section class="breadcrumb-nav">
    <div class="container">
        <a href="index.php">Home</a> /
        <a href="brand.php?manufacturer_id=<?= (int) $manufacturerId ?>"><?= e($variant['manufacturer_name'] ?? 'Brand') ?></a> /
        <a href="model.php?model_name=<?= urlencode($variant['model_name'] ?? '') ?>"><?= e($variant['model_name'] ?? '') ?></a> /
        <span><?= e($variant['variant_name'] ?? '') ?></span>
    </div>
</section>

<section class="hero hero-small">
    <div class="container">
        <h1><?= e(($variant['manufacturer_name'] ?? '') . ' ' . ($variant['model_name'] ?? '') . ' ' . ($variant['variant_name'] ?? '')) ?></h1>
        <p>Complete specifications, features, and pricing.</p>
    </div>
</section>

<div class="container">
    <section class="section">
        <div class="card variant-header">
            <div class="variant-info">
                <div>
                    <h2><?= e($variant['variant_name'] ?? '') ?></h2>
                    <div class="badges">
                        <?php if (!empty($variant['fuel_type'])): ?>
                            <span class="badge badge-info"><?= e($variant['fuel_type']) ?></span>
                        <?php endif; ?>
                        <?php if (!empty($variant['transmission'])): ?>
                            <span class="badge badge-success"><?= e($variant['transmission']) ?></span>
                        <?php endif; ?>
                    </div>
                    <?php if (!empty($variant['body_type'])): ?>
                        <p class="small">Body: <?= e($variant['body_type']) ?></p>
                    <?php endif; ?>
                </div>
                <div class="variant-actions">
                    <button class="btn btn-outline fav-button"
                            data-variant-id="<?= (int) $variantId ?>"
                            data-is-favorite="<?= $isFavorite ? '1' : '0' ?>">
                        <?= $isFavorite ? '✖ Remove' : '★ Save' ?>
                    </button>
                    <a href="compare.php?ids=<?= (int) $variantId ?>" class="btn btn-outline">Compare</a>
                </div>
            </div>
            <?php if (!empty($variant['ex_showroom_price'])): ?>
                <div class="variant-price">
                    <p class="price-label">Ex-Showroom Price</p>
                    <p class="price"><?= format_price((float) $variant['ex_showroom_price']) ?></p>
                </div>
            <?php endif; ?>
        </div>
    </section>

    <section class="section">
        <div class="tabs">
            <button class="tab-button active" data-tab="specifications">Specifications</button>
            <button class="tab-button" data-tab="features">Features</button>
            <button class="tab-button" data-tab="pricing">Pricing</button>
        </div>

        <div class="tab-panel active" id="specifications">
            <div class="card">
                <h3>Technical Specifications</h3>
                <p>Detailed specs are not available for this variant yet.</p>
            </div>
        </div>

        <div class="tab-panel" id="features">
            <div class="card">
                <h3>Features & Amenities</h3>
                <p>Features not available.</p>
            </div>
        </div>

        <div class="tab-panel" id="pricing">
            <div class="card">
                <h3>Pricing</h3>
                <?php if (!empty($variant['ex_showroom_price'])): ?>
                    <p class="price"><?= format_price((float) $variant['ex_showroom_price']) ?></p>
                <?php else: ?>
                    <p>Pricing information not available.</p>
                <?php endif; ?>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="section-header">
            <h2>Other Variants</h2>
        </div>
        <div class="grid grid-responsive">
            <?php
            $otherVariants = array_values(array_filter($modelVariants, static fn($v, $idx) => ($idx + 1) !== $variantId, ARRAY_FILTER_USE_BOTH));
            if (!empty($otherVariants)):
                foreach (array_slice($otherVariants, 0, 3) as $idx => $other):
                    $otherId = $idx + 1;
            ?>
                <article class="card">
                    <h4><?= e($other['name'] ?? '') ?></h4>
                    <p class="small"><?= e($other['fuel_type'] ?? 'Petrol') ?> · <?= e($other['transmission'] ?? 'MT') ?></p>
                    <?php if (!empty($other['price_numeric'])): ?>
                        <p class="price"><?= format_price((float) $other['price_numeric']) ?></p>
                    <?php endif; ?>
                    <a href="variant.php?variant_id=<?= (int) $otherId ?>&model_name=<?= urlencode($variant['model_name'] ?? '') ?>" class="btn btn-outline">View</a>
                </article>
            <?php
                endforeach;
            else:
                ?>
                <p>No other variants available.</p>
            <?php endif; ?>
        </div>
    </section>
</div>

<script>
document.querySelector('.fav-button')?.addEventListener('click', function() {
    const variantId = this.dataset.variantId;
    const isFavorite = this.dataset.isFavorite === '1';
    const action = isFavorite ? 'remove' : 'add';

    fetch(`api/favorites.php?action=${action}&variant_id=${variantId}`)
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                this.dataset.isFavorite = action === 'add' ? '1' : '0';
                this.textContent = action === 'add' ? '✖ Remove' : '★ Save';
            }
        });
});

document.querySelectorAll('.tab-button').forEach(button => {
    button.addEventListener('click', function() {
        const tabName = this.dataset.tab;
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.tab-button').forEach(b => b.classList.remove('active'));

        document.getElementById(tabName)?.classList.add('active');
        this.classList.add('active');
    });
});
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
