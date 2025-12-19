<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/repository.php';
require_once __DIR__ . '/views/partials/car_card.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$featuredManufacturers = array_slice(get_all_manufacturers(), 0, 8);
$featuredFamilies = get_featured_families(6);
$featuredVariants = get_featured_variants(6);
?>

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft">Car Research</p>
            <h1>Research, compare, and decide faster.</h1>
            <p>Browse India-market cars, filter by price and fuel, then dive into variants with clean spec tables.</p>
            <?php include __DIR__ . '/views/partials/search_bar.php'; ?>
            <div class="pill-row">
                <a class="pill" href="search.php?max_budget=500000">Under 5L</a>
                <a class="pill" href="search.php?min_budget=500000&max_budget=1000000">5-10L</a>
                <a class="pill" href="search.php?min_budget=1000000&max_budget=2000000">10-20L</a>
                <a class="pill" href="search.php?body_type=SUV">SUV</a>
                <a class="pill" href="search.php?body_type=Hatchback">Hatchback</a>
                <a class="pill" href="search.php?fuel_type=Electric">Electric</a>
            </div>
            <div class="stat-row" style="margin-top: 20px;">
                <div class="stat">
                    <p class="muted">Active brands</p>
                    <strong><?= e((string) count($featuredManufacturers)) ?></strong>
                </div>
                <div class="stat">
                    <p class="muted">Model families</p>
                    <strong><?= e((string) count($featuredFamilies)) ?></strong>
                </div>
                <div class="stat">
                    <p class="muted">Variants tracked</p>
                    <strong><?= e((string) count($featuredVariants)) ?></strong>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <p class="muted">Top brands</p>
                <h2>Browse by make</h2>
            </div>
            <a class="btn btn-outline" href="brand.php">View all</a>
        </div>
        <?php if (empty($featuredManufacturers)): ?>
            <?php render_empty_state('No brands yet', 'Add data to see brands here', 'Refresh', 'index.php'); ?>
        <?php else: ?>
            <div class="grid">
                <?php foreach ($featuredManufacturers as $man): ?>
                    <article class="card">
                        <p class="muted">Make</p>
                        <h3><?= e($man['name']) ?></h3>
                        <?php if (!empty($man['country'])): ?>
                            <span class="badge badge-info"><?= e($man['country']) ?></span>
                        <?php endif; ?>
                        <div class="card-footer">
                            <a class="btn btn-primary" href="brand.php?manufacturer_id=<?= (int) $man['id'] ?>">View models</a>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <p class="muted">Fresh models</p>
                <h2>Model families</h2>
            </div>
        </div>
        <?php if (empty($featuredFamilies)): ?>
            <?php render_empty_state('No families yet', 'Add model data to surface families', 'Search cars', 'search.php'); ?>
        <?php else: ?>
            <div class="grid">
                <?php foreach ($featuredFamilies as $family): ?>
                    <article class="card">
                        <p class="muted"><?= e($family['manufacturer_name']) ?></p>
                        <h3><?= e($family['nameplate']) ?></h3>
                        <div class="badge-row">
                            <?php if (!empty($family['body_type'])): ?>
                                <span class="badge badge-info"><?= e($family['body_type']) ?></span>
                            <?php endif; ?>
                            <?php if (!empty($family['segment'])): ?>
                                <span class="badge badge-success"><?= e($family['segment']) ?></span>
                            <?php endif; ?>
                        </div>
                        <?php if (!empty($family['fuel_scope'])): ?>
                            <p class="muted">Fuel: <?= e($family['fuel_scope']) ?></p>
                        <?php endif; ?>
                        <div class="card-footer">
                            <a class="btn btn-primary" href="brand.php?manufacturer_id=<?= (int) $family['manufacturer_id'] ?>">View brand</a>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <p class="muted">Trending trims</p>
                <h2>Latest variants</h2>
            </div>
            <a class="btn btn-outline" href="search.php">Search all</a>
        </div>
        <div class="grid">
            <?php if (empty($featuredVariants)): ?>
                <?php render_empty_state('No variants available', 'Add data to see trims here'); ?>
            <?php else: ?>
                <?php foreach ($featuredVariants as $variant): ?>
                    <article class="card">
                        <h3><?= e($variant['manufacturer_name']) ?> <?= e($variant['model_name']) ?></h3>
                        <p class="muted"><?= e($variant['variant_name']) ?></p>
                        <div class="badge-row">
                            <?php if (!empty($variant['fuel_type'])): ?>
                                <span class="badge badge-success"><?= e($variant['fuel_type']) ?></span>
                            <?php endif; ?>
                            <?php if (!empty($variant['transmission'])): ?>
                                <span class="badge badge-warning"><?= e($variant['transmission']) ?></span>
                            <?php endif; ?>
                        </div>
                        <?php if (!empty($variant['ex_showroom_price'])): ?>
                            <p class="muted">Price</p>
                            <p class="price"><?= format_price((float) $variant['ex_showroom_price']) ?></p>
                        <?php endif; ?>
                        <div class="card-footer">
                            <a class="btn btn-primary" href="variant.php?variant_id=<?= (int) $variant['id'] ?>">View Variant</a>
                            <button class="btn btn-outline btn-sm" type="button" data-compare-add="<?= e($variant['model_name']) ?>" data-compare-label="<?= e($variant['manufacturer_name'] . ' ' . $variant['variant_name']) ?>">Add to Compare</button>
                        </div>
                    </article>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
