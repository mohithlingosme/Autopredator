<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/repository.php';

$featuredManufacturers = array_slice(get_all_manufacturers(), 0, 8);
$featuredFamilies = get_featured_families(6);
$featuredVariants = get_featured_variants(6);
?>

<style>
:root {
    --primary: #d62828;
    --primary-dark: #a30000;
    --primary-light: #fce5e5;
    --secondary: #111217;
    --text: #f6f6f6;
    --text-light: #c7c7c7;
    --bg: #0b0b0f;
    --bg-light: #15151d;
    --border: #1f1f28;
    --shadow: 0 18px 50px rgba(0, 0, 0, 0.35);
}
body {
    background: radial-gradient(circle at 20% 20%, rgba(214,40,40,0.08), transparent 35%),
                radial-gradient(circle at 80% 0%, rgba(214,40,40,0.12), transparent 30%),
                #0b0b0f;
    color: var(--text);
}
.hero-xl {
    background: linear-gradient(135deg, rgba(214,40,40,0.92), rgba(15,15,20,0.95));
    border-radius: 22px;
    padding: 56px 48px;
    box-shadow: var(--shadow);
    position: relative;
    overflow: hidden;
}
.hero-xl::after {
    content: "";
    position: absolute;
    inset: 0;
    background: radial-gradient(circle at 70% 20%, rgba(255,255,255,0.12), transparent 40%);
    pointer-events: none;
}
.hero-grid {
    display: grid;
    grid-template-columns: 1.1fr 0.9fr;
    gap: 32px;
}
.stat-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 16px;
    margin-top: 28px;
}
.stat {
    background: rgba(0,0,0,0.25);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 14px;
    padding: 16px;
    text-align: left;
}
.stat strong { font-size: 1.4rem; color: #fff; display: block; }
.pill-row { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 14px; }
.pill {
    padding: 8px 12px;
    border-radius: 999px;
    background: rgba(255,255,255,0.08);
    color: #fff;
    border: 1px solid rgba(255,255,255,0.12);
    text-decoration: none;
}
.panel {
    background: var(--bg-light);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 22px;
    box-shadow: var(--shadow);
}
.section-header h2 { color: #fff; }
.card {
    background: var(--bg-light);
    border: 1px solid var(--border);
    color: var(--text);
    box-shadow: var(--shadow);
}
.card .price { color: #ffb3b3; }
.badge-info { background: rgba(214,40,40,0.18); color: #ffd5d5; border: 1px solid rgba(214,40,40,0.3); }
.badge-success { background: rgba(255,255,255,0.08); color: #fff; border: 1px solid rgba(255,255,255,0.12); }
.badge-warning { background: rgba(255,255,255,0.08); color: #fff; border: 1px solid rgba(255,255,255,0.12); }
.btn-primary { background: var(--primary); border-color: var(--primary-dark); }
.btn-outline { border-color: rgba(255,255,255,0.2); color: #fff; }
.grid-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 18px;
}
@media (max-width: 960px) { .hero-grid { grid-template-columns: 1fr; } }
</style>

<section class="container" style="margin-top: 24px;">
    <div class="hero-xl">
        <div class="hero-grid">
            <div>
                <p class="badge badge-info" style="display:inline-flex;">Autopredator Research</p>
                <h1 style="margin:12px 0 8px;font-size:2.4rem;color:#fff;">Research New & Used Cars – Compare Prices & Specs</h1>
                <p style="color: var(--text-light); max-width: 640px;">Browse Indian-market cars, compare real variants, and see pricing in seconds.</p>
                <form action="search.php" method="get" class="search-form" style="margin-top:18px;">
                    <input type="search" name="q" placeholder="Search by brand, model or keyword" aria-label="Search cars">
                    <button class="btn btn-primary" type="submit">Search</button>
                </form>
                <div class="pill-row">
                    <a class="pill" href="search.php?max_budget=500000">Under ₹5L</a>
                    <a class="pill" href="search.php?min_budget=500000&max_budget=1000000">₹5-10L</a>
                    <a class="pill" href="search.php?min_budget=1000000&max_budget=2000000">₹10-20L</a>
                    <a class="pill" href="search.php?body_type=SUV">SUV</a>
                    <a class="pill" href="search.php?body_type=Hatchback">Hatchback</a>
                    <a class="pill" href="search.php?fuel_type=Electric">Electric</a>
                </div>
                <div style="margin-top: 16px;">
                    <a class="btn btn-primary" href="search.php" style="margin-right: 12px;">Find a Car</a>
                    <a class="btn btn-outline" href="compare.php">Compare Cars</a>
                </div>
            </div>
            <div class="panel">
                <h3 style="margin-bottom:8px;">Quick Picks</h3>
                <div class="stat-row">
                    <div class="stat"><strong><?= count($featuredManufacturers) ?></strong><span>Active brands</span></div>
                    <div class="stat"><strong><?= count($featuredFamilies) ?></strong><span>Model families</span></div>
                    <div class="stat"><strong><?= count($featuredVariants) ?></strong><span>Variants tracked</span></div>
                </div>
                <div style="margin-top:16px;">
                    <h4 style="margin-bottom:8px;">Popular shortcuts</h4>
                    <div class="pill-row">
                        <a class="pill" href="brand.php?manufacturer_id=1">Maruti Suzuki</a>
                        <a class="pill" href="brand.php?manufacturer_id=2">Toyota</a>
                        <a class="pill" href="compare.php">Open Compare</a>
                        <a class="pill" href="my_garage.php">My Garage</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="section container">
    <div class="section-header">
        <h2>Popular Brands</h2>
        <p>Active brands in the database</p>
    </div>
    <div class="grid-cards">
        <?php foreach ($featuredManufacturers as $man): ?>
            <article class="card">
                <h3><?= e($man['name']) ?></h3>
                <?php if (!empty($man['country'])): ?>
                    <p class="badge badge-info"><?= e($man['country']) ?></p>
                <?php endif; ?>
                <a class="btn btn-outline" href="brand.php?manufacturer_id=<?= (int) $man['id'] ?>">View Models</a>
            </article>
        <?php endforeach; ?>
    </div>
</section>

<section class="section container">
    <div class="section-header">
        <h2>Model Families</h2>
        <p>Latest families with active models</p>
    </div>
    <div class="grid-cards">
        <?php foreach ($featuredFamilies as $family): ?>
            <article class="card">
                <h3><?= e($family['manufacturer_name']) ?> <?= e($family['nameplate']) ?></h3>
                <div class="badge-row">
                    <?php if (!empty($family['body_type'])): ?>
                        <span class="badge badge-info"><?= e($family['body_type']) ?></span>
                    <?php endif; ?>
                    <?php if (!empty($family['segment'])): ?>
                        <span class="badge badge-success"><?= e($family['segment']) ?></span>
                    <?php endif; ?>
                </div>
                <?php if (!empty($family['fuel_scope'])): ?>
                    <p class="small">Fuel: <?= e($family['fuel_scope']) ?></p>
                <?php endif; ?>
                <div class="card-footer">
                    <a class="btn btn-primary" href="brand.php?manufacturer_id=<?= (int) $family['manufacturer_id'] ?>">View brand</a>
                    <a class="btn btn-outline" href="model.php?family_id=<?= (int) $family['id'] ?>">View models</a>
                </div>
            </article>
        <?php endforeach; ?>
    </div>
</section>

<section class="section container">
    <div class="section-header">
        <h2>Latest Variants</h2>
        <p>Recently added trims with pricing</p>
    </div>
    <div class="grid-cards">
        <?php if (empty($featuredVariants)): ?>
            <article class="card">
                <p>No variants available yet. Add data to see it here.</p>
            </article>
        <?php endif; ?>

        <?php foreach ($featuredVariants as $variant): ?>
            <article class="card">
                <h3><?= e($variant['manufacturer_name']) ?> <?= e($variant['model_name']) ?></h3>
                <p class="small"><?= e($variant['variant_name']) ?></p>
                <div class="badge-row">
                    <?php if (!empty($variant['fuel_type'])): ?>
                        <span class="badge badge-success"><?= e($variant['fuel_type']) ?></span>
                    <?php endif; ?>
                    <?php if (!empty($variant['transmission'])): ?>
                        <span class="badge badge-warning"><?= e($variant['transmission']) ?></span>
                    <?php endif; ?>
                </div>
                <?php if (!empty($variant['ex_showroom_price'])): ?>
                    <p class="price"><?= format_price((float) $variant['ex_showroom_price']) ?></p>
                <?php endif; ?>
                <a class="btn btn-primary" href="variant.php?variant_id=<?= (int) $variant['id'] ?>">View Variant</a>
            </article>
        <?php endforeach; ?>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
