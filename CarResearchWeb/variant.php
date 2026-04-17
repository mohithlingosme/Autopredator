<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$variantId = (int) ($_GET['variant_id'] ?? 0);
$variantSlug = trim($_GET['variant_slug'] ?? $_GET['slug'] ?? '');
$modelName = trim($_GET['model_name'] ?? '');
$variantNameParam = trim($_GET['variant'] ?? '');

$variant = null;

if ($variantSlug !== '') {
    $variant = repo()->getVariantBySlug($variantSlug);
} elseif ($variantId > 0) {
    $variant = repo()->getVariantById($variantId);
} elseif ($modelName !== '' && $variantNameParam !== '') {
    $variants = car_service()->getVariantsByModel($modelName);
    foreach ($variants as $index => $v) {
        if (strcasecmp($v['name'], $variantNameParam) === 0) {
            $resolvedId = isset($v['id']) ? (int) $v['id'] : ($index + 1);
            $variant = [
                'id' => $resolvedId,
                'variant' => $v['name'],
                'slug' => $v['slug'] ?? slugify($v['name']),
                'fuel_type' => $v['fuel_type'],
                'transmission' => $v['transmission'],
                'price_numeric' => $v['price_numeric'] ?? null,
                'model' => $modelName,
                'brand' => $v['brand'] ?? '',
                'manufacturer_id' => 0,
                'model_id' => $resolvedId,
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
$variantSlug = $variant['slug'] ?? $variantSlug;
$manufacturerId = (int) ($variant['manufacturer_id'] ?? 0);
$modelName = $variant['model_name'] ?? $variant['model'] ?? $modelName;
$brandName = $variant['manufacturer_name'] ?? $variant['brand'] ?? '';
$variantName = $variant['variant_name'] ?? $variant['variant'] ?? ($variant['name'] ?? '');
$priceValue = $variant['ex_showroom_price'] ?? $variant['price_numeric'] ?? null;
$hasPrice = $priceValue !== null && $priceValue > 0;
$images = is_array($variant['images'] ?? null) ? $variant['images'] : [];
$primaryImage = $variant['image_url'] ?? null;
foreach ($images as $img) {
    if (!empty($img['image_url']) && (int) ($img['is_thumbnail'] ?? 0) === 1) {
        $primaryImage = $img['image_url'];
        break;
    }
    if ($primaryImage === null && !empty($img['image_url'])) {
        $primaryImage = $img['image_url'];
    }
}
$primaryImage = $primaryImage ?: '/assets/img/no-car-image.png';

$modelVariants = car_service()->getVariantsByModel($modelName);
$favorites = fav_get_list();
$isFavorite = in_array($variantId, $favorites, true);
$page_title = ($variantName ?: 'Variant') . ' - ' . $brandName . ' | Autopredator';

// Breadcrumbs
$breadcrumbs = [
    ['url' => 'index.php', 'label' => 'Home'],
    ['url' => 'brand.php', 'label' => 'Brands'],
    ['url' => 'brand.php?brandSlug=' . urlencode(slugify($brandName)), 'label' => $brandName],
    ['url' => 'model.php?brandSlug=' . urlencode(slugify($brandName)) . '&modelSlug=' . urlencode(slugify($modelName)), 'label' => $modelName],
    ['url' => '', 'label' => $variantName],
];

// Render breadcrumbs
require_once __DIR__ . '/views/partials/breadcrumbs.php';
render_breadcrumbs($breadcrumbs);
?>

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft">Variant</p>
            <h1><?= e(trim($brandName . ' ' . $modelName . ' ' . $variantName)) ?></h1>
            <p>Complete specifications, features, and pricing.</p>
            <div class="pill-row">
                <?php if (!empty($variant['fuel_type'])): ?><span class="pill">Fuel: <?= e($variant['fuel_type']) ?></span><?php endif; ?>
                <?php if (!empty($variant['transmission'])): ?><span class="pill">Transmission: <?= e($variant['transmission']) ?></span><?php endif; ?>
                <?php if (!empty($variant['body_type'])): ?><span class="pill">Body: <?= e($variant['body_type']) ?></span><?php endif; ?>
            </div>
            <?php if ($hasPrice): ?>
                <div class="price" style="margin-top: 16px; font-size: 1.5rem; font-weight: bold; color: var(--color-primary);">
                    <?= format_price((float) $priceValue) ?>
                </div>
            <?php else: ?>
                <span class="badge badge-soft" style="margin-top: 12px; background:#e5e7eb; color:#4b5563;">Price not available</span>
            <?php endif; ?>
            <div class="hero-media" style="margin-top:16px;">
                <img src="<?= e($primaryImage) ?>" alt="<?= e($brandName . ' ' . $modelName . ' ' . $variantName) ?>" style="width:100%;max-width:520px;border-radius:12px;object-fit:cover;aspect-ratio:16/9;" onerror="this.src='/assets/img/no-car-image.png';">
            </div>
            <div class="card-footer" style="padding: 0; margin-top: 16px;">
                <button class="btn btn-primary" type="button" data-compare-add="<?= e($variantSlug) ?>" data-compare-label="<?= e($variantName) ?>">Add to Compare</button>
                <a class="btn btn-outline" href="compare.php?ids=<?= urlencode($variantSlug) ?>">Compare This</a>
                <button class="btn btn-outline" type="button" data-shortlist-add="<?= e($modelName) ?>" data-shortlist-label="<?= e($variantName) ?>">Shortlist</button>
                <button class="btn btn-outline" type="button" onclick="navigator.share({title: '<?= e($variantName) ?>', url: window.location.href})">Share</button>
            </div>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <h2>Highlights</h2>
        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
            <div class="card">
                <p class="muted">Power</p>
                <strong><?php if (!empty($variant['max_power_bhp'])): ?><?= e($variant['max_power_bhp']) ?> bhp<?php elseif (!empty($variant['horsepower'])): ?><?= e($variant['horsepower']) ?> bhp<?php else: ?>—<?php endif; ?></strong>
            </div>
            <div class="card">
                <p class="muted">Torque</p>
                <strong><?php if (!empty($variant['max_torque_nm'])): ?><?= e($variant['max_torque_nm']) ?> Nm<?php else: ?>—<?php endif; ?></strong>
            </div>
            <div class="card">
                <p class="muted">Mileage</p>
                <strong><?php if (!empty($variant['mileage_city_kmpl'])): ?><?= e($variant['mileage_city_kmpl']) ?> kmpl<?php elseif (!empty($variant['range_mileage'])): ?><?= e($variant['range_mileage']) ?> kmpl<?php else: ?>—<?php endif; ?></strong>
            </div>
            <div class="card">
                <p class="muted">Fuel Type</p>
                <strong><?php if (!empty($variant['fuel_type'])): ?><?= e($variant['fuel_type']) ?><?php else: ?>—<?php endif; ?></strong>
            </div>
            <div class="card">
                <p class="muted">Transmission</p>
                <strong><?php if (!empty($variant['transmission'])): ?><?= e($variant['transmission']) ?><?php else: ?>—<?php endif; ?></strong>
            </div>
            <div class="card">
                <p class="muted">Seats</p>
                <strong><?php if (!empty($variant['seating_capacity'])): ?><?= e($variant['seating_capacity']) ?><?php else: ?>—<?php endif; ?></strong>
            </div>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="tabs">
            <button class="tab-btn active" data-tab="engine-performance">Engine/Performance</button>
            <button class="tab-btn" data-tab="economy">Economy</button>
            <button class="tab-btn" data-tab="dimensions">Dimensions</button>
            <button class="tab-btn" data-tab="safety">Safety</button>
            <button class="tab-btn" data-tab="features">Features</button>
        </div>

        <div class="tab-content active" id="engine-performance">
            <div class="card">
                <h3>Engine/Performance</h3>
                <div class="spec-grid">
                    <div class="spec-item"><p class="muted">Engine Type</p><strong><?= e(display_value($variant['engine_type'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Displacement</p><strong><?= e(display_value($variant['engine_displacement_cc'] ?? null)) ?> cc</strong></div>
                    <div class="spec-item"><p class="muted">Max Power</p><strong><?= e(display_value($variant['max_power_bhp'] ?? $variant['horsepower'] ?? null)) ?> bhp</strong></div>
                    <div class="spec-item"><p class="muted">Max Torque</p><strong><?= e(display_value($variant['max_torque_nm'] ?? null)) ?> Nm</strong></div>
                    <div class="spec-item"><p class="muted">Transmission</p><strong><?= e(display_value($variant['transmission'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Gears</p><strong><?= e(display_value($variant['no_of_gears'] ?? null)) ?></strong></div>
                </div>
            </div>
        </div>

        <div class="tab-content" id="economy">
            <div class="card">
                <h3>Economy</h3>
                <div class="spec-grid">
                    <div class="spec-item"><p class="muted">Fuel</p><strong><?= e(display_value($variant['fuel_type'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Mileage</p><strong><?= e(display_value($variant['mileage_city_kmpl'] ?? $variant['range_mileage'] ?? null)) ?> kmpl</strong></div>
                    <div class="spec-item"><p class="muted">Range</p><strong><?= e(display_value($variant['range_km'] ?? null)) ?> km</strong></div>
                    <div class="spec-item"><p class="muted">Fuel Tank</p><strong><?= e(display_value($variant['fuel_tank_capacity_litres'] ?? null)) ?> L</strong></div>
                </div>
            </div>
        </div>

        <div class="tab-content" id="engine">
            <div class="card">
                <h3>Engine & Transmission</h3>
                <div class="spec-grid">
                    <div class="spec-item"><p class="muted">Engine Type</p><strong><?= e(display_value($variant['engine_type'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Displacement</p><strong><?= e(display_value($variant['engine_displacement_cc'] ?? null)) ?> cc</strong></div>
                    <div class="spec-item"><p class="muted">Max Power</p><strong><?= e(display_value($variant['max_power_bhp'] ?? $variant['horsepower'] ?? null)) ?> bhp</strong></div>
                    <div class="spec-item"><p class="muted">Max Torque</p><strong><?= e(display_value($variant['max_torque_nm'] ?? null)) ?> Nm</strong></div>
                    <div class="spec-item"><p class="muted">Transmission</p><strong><?= e(display_value($variant['transmission'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Gears</p><strong><?= e(display_value($variant['no_of_gears'] ?? null)) ?></strong></div>
                </div>
            </div>
        </div>

        <div class="tab-content" id="dimensions">
            <div class="card">
                <h3>Dimensions</h3>
                <div class="spec-grid">
                    <div class="spec-item"><p class="muted">Length</p><strong><?= e(display_value($variant['length_mm'] ?? null)) ?> mm</strong></div>
                    <div class="spec-item"><p class="muted">Width</p><strong><?= e(display_value($variant['width_mm'] ?? null)) ?> mm</strong></div>
                    <div class="spec-item"><p class="muted">Height</p><strong><?= e(display_value($variant['height_mm'] ?? null)) ?> mm</strong></div>
                    <div class="spec-item"><p class="muted">Wheelbase</p><strong><?= e(display_value($variant['wheelbase_mm'] ?? null)) ?> mm</strong></div>
                    <div class="spec-item"><p class="muted">Ground Clearance</p><strong><?= e(display_value($variant['ground_clearance_mm'] ?? null)) ?> mm</strong></div>
                    <div class="spec-item"><p class="muted">Boot Space</p><strong><?= e(display_value($variant['boot_space_litres'] ?? null)) ?> L</strong></div>
                </div>
            </div>
        </div>

        <div class="tab-content" id="safety">
            <div class="card">
                <h3>Safety</h3>
                <div class="spec-grid">
                    <div class="spec-item"><p class="muted">Airbags</p><strong><?= e(display_value($variant['airbags'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">ABS</p><strong><?= e(display_value($variant['abs'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">EBD</p><strong><?= e(display_value($variant['ebd'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">ESP</p><strong><?= e(display_value($variant['esp'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Traction Control</p><strong><?= e(display_value($variant['traction_control'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Hill Assist</p><strong><?= e(display_value($variant['hill_assist'] ?? null)) ?></strong></div>
                </div>
            </div>
        </div>

        <div class="tab-content" id="features">
            <div class="card">
                <h3>Features</h3>
                <div class="spec-grid">
                    <div class="spec-item"><p class="muted">AC</p><strong><?= e(display_value($variant['ac'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Power Steering</p><strong><?= e(display_value($variant['power_steering'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Central Locking</p><strong><?= e(display_value($variant['central_locking'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Music System</p><strong><?= e(display_value($variant['music_system'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">Bluetooth</p><strong><?= e(display_value($variant['bluetooth'] ?? null)) ?></strong></div>
                    <div class="spec-item"><p class="muted">USB</p><strong><?= e(display_value($variant['usb'] ?? null)) ?></strong></div>
                </div>
            </div>
        </div>
    </div>
</section>

<div class="container" style="padding: 0 0 32px;">
    <div class="filter-shell" style="grid-template-columns: 320px 1fr;">
        <aside class="sticky-summary">
            <?php if ($hasPrice): ?>
                <p class="muted">Ex-showroom</p>
                <h3><?= format_price((float) $priceValue) ?></h3>
            <?php else: ?>
                <span class="badge badge-soft" style="background:#e5e7eb; color:#4b5563;">Price not available</span>
            <?php endif; ?>
            <div class="card-footer" style="padding:0; margin-top:12px;">
                <button class="btn btn-primary" type="button" data-compare-add="<?= e($variantSlug) ?>" data-compare-label="<?= e($variantName) ?>">Add to Compare</button>
                <button class="btn btn-outline" type="button" data-fav-toggle data-id="<?= (int) $variantId ?>" data-active="<?= $isFavorite ? '1' : '0' ?>"><?= $isFavorite ? 'Remove Favorite' : 'Save Favorite' ?></button>
            </div>
            <div style="margin-top:16px;">
                <p class="muted">Other variants</p>
                <?php
                $otherVariants = array_values(array_filter(
                    $modelVariants,
                    static fn($v) => ($v['slug'] ?? $v['id'] ?? null) !== ($variantSlug ?: $variantId)
                ));
                if (empty($otherVariants)):
                ?>
                    <p class="muted">No other variants listed.</p>
                <?php else: ?>
                    <ul style="padding-left:16px;">
                <?php foreach ($otherVariants as $idx => $other):
                    $otherSlug = $other['slug'] ?? slugify($other['name'] ?? (string) ($other['variant'] ?? ''));
                ?>
                    <li><a class="muted" href="variant.php?variant_slug=<?= urlencode($otherSlug) ?>"><?= e($other['name'] ?? $other['variant'] ?? '') ?></a></li>
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
                    <?php if ($hasPrice): ?>
                        <p class="muted">Ex-Showroom Price</p>
                        <p class="price"><?= format_price((float) $priceValue) ?></p>
                    <?php else: ?>
                        <span class="badge badge-soft" style="background:#e5e7eb; color:#4b5563;">Price not available</span>
                    <?php endif; ?>
                </div>
            </section>
        </main>
    </div>
</div>

<section class="section">
    <div class="container">
        <h2>Similar Cars</h2>
        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));">
            <?php
            $similarCars = car_service()->getModelsByBrand($brandName);
            $similarCars = array_filter($similarCars, static fn($car) => ($car['model'] ?? '') !== $modelName);
            $similarCars = array_slice($similarCars, 0, 3); // Limit to 3 similar cars
            foreach ($similarCars as $car):
            ?>
                <article class="card car-card">
                    <div class="card-top">
                        <p class="muted"><?= e($car['make'] ?? $brandName) ?></p>
                        <h3><?= e($car['model'] ?? '') ?></h3>
                        <?php if (!empty($car['segment'])): ?>
                            <span class="badge badge-soft"><?= e($car['segment']) ?></span>
                        <?php endif; ?>
                    </div>
                    <div class="card-body">
                        <div class="stat-row">
                            <?php if (!empty($car['price_range']['min'])): ?>
                                <div class="stat">
                                    <p class="muted">Price</p>
                                    <strong><?= format_price((float) $car['price_range']['min']) ?><?php if (!empty($car['price_range']['max']) && $car['price_range']['max'] !== $car['price_range']['min']): ?> - <?= format_price((float) $car['price_range']['max']) ?><?php endif; ?></strong>
                                </div>
                            <?php endif; ?>
                            <?php if (!empty($car['fuel_types'])): ?>
                                <div class="stat">
                                    <p class="muted">Fuel</p>
                                    <strong><?= e(is_array($car['fuel_types']) ? implode(', ', $car['fuel_types']) : $car['fuel_types']) ?></strong>
                                </div>
                            <?php endif; ?>
                            <?php if (!empty($car['variants'][0]['horsepower'])): ?>
                                <div class="stat">
                                    <p class="muted">Power</p>
                                    <strong><?= e($car['variants'][0]['horsepower']) ?> bhp</strong>
                                </div>
                            <?php endif; ?>
                            <?php if (!empty($car['variants'][0]['mileage_kmpl'])): ?>
                                <div class="stat">
                                    <p class="muted">Mileage</p>
                                    <strong><?= e($car['variants'][0]['mileage_kmpl']) ?> kmpl</strong>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="card-footer">
                        <?php
                        $carBrand = $car['make'] ?? $brandName;
                        $carModelSlug = $car['slug'] ?? slugify($car['model'] ?? '');
                        $carBrandSlug = $car['brand_slug'] ?? slugify($carBrand);
                        ?>
                        <a href="model.php?brandSlug=<?= urlencode($carBrandSlug) ?>&modelSlug=<?= urlencode($carModelSlug) ?>" class="btn btn-primary">View Variants</a>
                        <button class="btn btn-outline" type="button" data-compare-add="<?= e($carModelSlug) ?>" data-compare-label="<?= e(($car['make'] ?? $carBrand) . ' ' . ($car['model'] ?? '')) ?>">Add to Compare</button>
                    </div>
                </article>
            <?php endforeach; ?>
        </div>
    </div>
</section>

<script>
(function(){
    // Tab functionality
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', function(){
            const tab = this.getAttribute('data-tab');
            tabBtns.forEach(b => b.classList.remove('active'));
            tabContents.forEach(c => c.classList.remove('active'));
            this.classList.add('active');
            document.getElementById(tab).classList.add('active');
        });
    });

    // Favorites
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
