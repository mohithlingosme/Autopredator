<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/repository.php';
require_once __DIR__ . '/views/partials/empty_state.php';

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

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft">Variant</p>
            <h1><?= e(($variant['manufacturer_name'] ?? '') . ' ' . ($variant['model_name'] ?? '') . ' ' . ($variant['variant_name'] ?? '')) ?></h1>
            <p>Complete specifications, features, and pricing.</p>
            <div class="pill-row">
                <?php if (!empty($variant['fuel_type'])): ?><span class="pill">Fuel: <?= e($variant['fuel_type']) ?></span><?php endif; ?>
                <?php if (!empty($variant['transmission'])): ?><span class="pill">Transmission: <?= e($variant['transmission']) ?></span><?php endif; ?>
                <?php if (!empty($variant['body_type'])): ?><span class="pill">Body: <?= e($variant['body_type']) ?></span><?php endif; ?>
            </div>
        </div>
    </div>
</section>

<div class="container" style="padding: 0 0 32px;">
    <div class="filter-shell" style="grid-template-columns: 320px 1fr;">
        <aside class="sticky-summary">
            <?php if (!empty($variant['ex_showroom_price'])): ?>
                <p class="muted">Ex-showroom</p>
                <h3><?= format_price((float) $variant['ex_showroom_price']) ?></h3>
            <?php endif; ?>
            <div class="card-footer" style="padding:0; margin-top:12px;">
                <button class="btn btn-primary" type="button" data-compare-add="<?= e($variant['model_name'] ?? '') ?>" data-compare-label="<?= e($variant['variant_name'] ?? '') ?>">Add to Compare</button>
                <button class="btn btn-outline" type="button" data-fav-toggle data-id="<?= (int) $variantId ?>" data-active="<?= $isFavorite ? '1' : '0' ?>"><?= $isFavorite ? 'Remove Favorite' : 'Save Favorite' ?></button>
            </div>
            <div style="margin-top:16px;">
                <p class="muted">Other variants</p>
                <?php
                $otherVariants = array_values(array_filter($modelVariants, static fn($v, $idx) => ($idx + 1) !== $variantId, ARRAY_FILTER_USE_BOTH));
                if (empty($otherVariants)):
                ?>
                    <p class="muted">No other variants listed.</p>
                <?php else: ?>
                    <ul style="padding-left:16px;">
                        <?php foreach ($otherVariants as $idx => $other): $otherId = $idx + 1; ?>
                            <li><a class="muted" href="variant.php?variant_id=<?= (int) $otherId ?>&model_name=<?= urlencode($variant['model_name'] ?? '') ?>"><?= e($other['name'] ?? '') ?></a></li>
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
                        <div class="spec-item"><p class="muted">Fuel</p><strong><?= e(display_value($variant['fuel_type'] ?? null)) ?></strong></div>
                        <div class="spec-item"><p class="muted">Transmission</p><strong><?= e(display_value($variant['transmission'] ?? null)) ?></strong></div>
                        <div class="spec-item"><p class="muted">Body</p><strong><?= e(display_value($variant['body_type'] ?? null)) ?></strong></div>
                        <div class="spec-item"><p class="muted">Engine</p><strong><?= e(display_value($variant['engine_size'] ?? $variant['engine_displacement_cc'] ?? null)) ?></strong></div>
                        <div class="spec-item"><p class="muted">Power</p><strong><?= e(display_value($variant['max_power_bhp'] ?? $variant['horsepower'] ?? null)) ?></strong></div>
                        <div class="spec-item"><p class="muted">Mileage</p><strong><?= e(display_value($variant['mileage_city_kmpl'] ?? $variant['range_mileage'] ?? null)) ?></strong></div>
                    </div>
                </div>
            </section>

            <section class="section" style="padding-top:16px;">
                <div class="card">
                    <h2>Pricing</h2>
                    <?php if (!empty($variant['ex_showroom_price'])): ?>
                        <p class="muted">Ex-Showroom Price</p>
                        <p class="price"><?= format_price((float) $variant['ex_showroom_price']) ?></p>
                    <?php else: ?>
                        <p class="muted">Pricing information not available.</p>
                    <?php endif; ?>
                </div>
            </section>
        </main>
    </div>
</div>

<script>
(function(){
    const favBtn = document.querySelector('[data-fav-toggle]');
    favBtn?.addEventListener('click', function(){
        const active = this.getAttribute('data-active') === '1';
        const action = active ? 'remove' : 'add';
        const id = this.getAttribute('data-id');
        fetch(`api/favorites.php?action=${action}&variant_id=${id}`)
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    this.setAttribute('data-active', active ? '0' : '1');
                    this.textContent = active ? 'Save Favorite' : 'Remove Favorite';
                }
            });
    });
})();
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
