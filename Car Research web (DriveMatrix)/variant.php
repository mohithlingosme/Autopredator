<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/car_repository.php';
require_once __DIR__ . '/includes/auth.php';

$variantId = (int) ($_GET['variant_id'] ?? 0);
$variant = $variantId > 0 ? get_variant_by_id($variantId) : null;

if ($variant === null) {
    redirect('index.php');
}

$specs = get_specs_for_variant($variantId);
$features = get_grouped_features_for_variant($variantId);
$prices = get_prices_for_variant($variantId);
$favorites = fav_get_list();
$isFavorite = in_array($variantId, $favorites, true);
$page_title = $variant['variant_name'] . ' - ' . $variant['manufacturer_name'] . ' | Autopredator';
?>

<section class="breadcrumb-nav">
    <div class="container">
        <a href="index.php">Home</a> /
        <a href="brand.php?manufacturer_id=<?= (int) $variant['manufacturer_id'] ?>"><?= e($variant['manufacturer_name']) ?></a> /
        <a href="model.php?model_id=<?= (int) $variant['model_id'] ?>"><?= e($variant['model_name']) ?></a> /
        <span><?= e($variant['variant_name']) ?></span>
    </div>
</section>

<section class="hero hero-small">
    <div class="container">
        <h1><?= e($variant['manufacturer_name'] . ' ' . $variant['model_name'] . ' ' . $variant['variant_name']) ?></h1>
        <p>Complete specifications, features, and pricing.</p>
    </div>
</section>

<div class="container">
    <section class="section">
        <div class="card variant-header">
            <div class="variant-info">
                <div>
                    <h2><?= e($variant['variant_name']) ?></h2>
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
                        <?= $isFavorite ? '♥ Remove' : '♡ Save' ?>
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
                <?php if ($specs): ?>
                    <div class="specs-grid">
                        <div class="spec-item"><label>Engine Type</label><p><?= e($specs['engine_type'] ?? 'N/A') ?></p></div>
                        <div class="spec-item"><label>Displacement</label><p><?= e((string) ($specs['engine_displacement_cc'] ?? 'N/A')) ?> cc</p></div>
                        <div class="spec-item"><label>Max Power</label><p><?= e((string) ($specs['max_power_bhp'] ?? 'N/A')) ?> bhp</p></div>
                        <div class="spec-item"><label>Max Torque</label><p><?= e((string) ($specs['max_torque_nm'] ?? 'N/A')) ?> Nm</p></div>
                        <div class="spec-item"><label>Transmission</label><p><?= e($specs['transmission_type'] ?? $variant['transmission'] ?? 'N/A') ?></p></div>
                        <div class="spec-item"><label>Drivetrain</label><p><?= e($specs['drivetrain'] ?? 'N/A') ?></p></div>
                        <div class="spec-item"><label>Fuel Tank</label><p><?= e((string) ($specs['fuel_tank_capacity_ltr'] ?? 'N/A')) ?> L</p></div>
                        <div class="spec-item"><label>Seating</label><p><?= e((string) ($specs['seating_capacity'] ?? 'N/A')) ?> Seats</p></div>
                        <div class="spec-item"><label>Ground Clearance</label><p><?= e((string) ($specs['ground_clearance_mm'] ?? 'N/A')) ?> mm</p></div>
                        <div class="spec-item"><label>Boot Space</label><p><?= e((string) ($specs['boot_space_ltr'] ?? 'N/A')) ?> L</p></div>
                        <div class="spec-item"><label>Mileage (City)</label><p><?= e((string) ($specs['mileage_city_kmpl'] ?? 'N/A')) ?> kmpl</p></div>
                        <div class="spec-item"><label>Mileage (Highway)</label><p><?= e((string) ($specs['mileage_highway_kmpl'] ?? 'N/A')) ?> kmpl</p></div>
                    </div>
                <?php else: ?>
                    <p>Specifications not available.</p>
                <?php endif; ?>
            </div>
        </div>

        <div class="tab-panel" id="features">
            <div class="card">
                <h3>Features & Amenities</h3>
                <?php if (!empty($features)): ?>
                    <?php foreach ($features as $category => $featureList): ?>
                        <div class="feature-group">
                            <h4><?= e($category) ?></h4>
                            <ul class="feature-list">
                                <?php foreach ($featureList as $feature): ?>
                                    <li><?= e($feature['name'] ?? '') ?></li>
                                <?php endforeach; ?>
                            </ul>
                        </div>
                    <?php endforeach; ?>
                <?php else: ?>
                    <p>Features not available.</p>
                <?php endif; ?>
            </div>
        </div>

        <div class="tab-panel" id="pricing">
            <div class="card">
                <h3>Pricing</h3>
                <?php if (!empty($prices)): ?>
                    <div class="table-responsive">
                        <table class="table pricing-table">
                            <thead>
                                <tr>
                                    <th>Price</th>
                                    <th>Updated At</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($prices as $price): ?>
                                    <tr>
                                        <td class="price"><?= !empty($price['price']) ? format_price((float) $price['price']) : 'N/A' ?></td>
                                        <td><?= e($price['updated_at'] ?? '') ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
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
            $modelVariants = get_variants_by_model((int) $variant['model_id']);
            $otherVariants = array_values(array_filter($modelVariants, static fn($v) => (int) $v['id'] !== $variantId));
            if (!empty($otherVariants)):
                foreach (array_slice($otherVariants, 0, 3) as $other):
            ?>
                <article class="card">
                    <h4><?= e($other['variant_name']) ?></h4>
                    <p class="small"><?= e($other['fuel_type'] ?? 'Petrol') ?> • <?= e($other['transmission'] ?? 'MT') ?></p>
                    <?php if (!empty($other['ex_showroom_price'])): ?>
                        <p class="price"><?= format_price((float) $other['ex_showroom_price']) ?></p>
                    <?php endif; ?>
                    <a href="variant.php?variant_id=<?= (int) $other['id'] ?>" class="btn btn-outline">View</a>
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
                this.textContent = action === 'add' ? '♥ Remove' : '♡ Save';
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
