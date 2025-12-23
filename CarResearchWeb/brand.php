<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/views/partials/car_card.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$manufacturerId = (int) ($_GET['manufacturer_id'] ?? 0);
$manufacturerName = trim($_GET['manufacturer_name'] ?? '');
$manufacturer = car_service()->findBrandByIdOrName($manufacturerId, $manufacturerName);

$page_title = $manufacturer ? ($manufacturer['name'] . ' Cars & Models | Autopredator') : 'Manufacturers | Autopredator';
$page_description = $manufacturer
    ? 'Browse all ' . e($manufacturer['name']) . ' vehicles, compare models and find the best car for your budget.'
    : 'Browse all active manufacturers on Autopredator.';

// Breadcrumbs
$breadcrumbs = [
    ['url' => 'index.php', 'label' => 'Home'],
    ['url' => 'brand.php', 'label' => 'Brands'],
];
if ($manufacturer) {
    $breadcrumbs[] = ['url' => '', 'label' => $manufacturer['name']];
}

if ($manufacturer === null && $manufacturerId > 0) {
    redirect('brand.php');
}

if ($manufacturer === null) {
    $manufacturers = get_all_manufacturers();
    ?>
    <section class="hero">
        <div class="container">
            <div class="hero-card">
                <p class="badge badge-soft">All Brands</p>
                <h1>Pick a manufacturer</h1>
                <p>Choose a make to see all their models and trims. Data stays in sync with our JSON source.</p>
            </div>
        </div>
    </section>
    <section class="section">
        <div class="container">
            <?php if (empty($manufacturers)): ?>
                <?php render_empty_state('No brands found', 'Add data to see brands', 'Refresh', 'brand.php'); ?>
            <?php else: ?>
                <div class="grid">
                    <?php foreach ($manufacturers as $man): ?>
                        <article class="card">
                            <p class="muted">Make</p>
                            <h3><?= e($man['name']) ?></h3>
                            <?php if (!empty($man['country'])): ?>
                                <span class="badge badge-info"><?= e($man['country']) ?></span>
                            <?php endif; ?>
                            <div class="card-footer">
                                <a href="brand.php?manufacturer_id=<?= (int) $man['id'] ?>" class="btn btn-primary">View Models</a>
                            </div>
                        </article>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
    </section>
    <?php
    require_once __DIR__ . '/includes/footer.php';
    exit;
}

$models = car_service()->getModelsByBrand($manufacturer['name']);

// Collect all variants for Variants tab
$allVariants = [];
foreach ($models as $model) {
    foreach ($model['variants'] ?? [] as $variant) {
        $allVariants[] = array_merge($variant, [
            'model_name' => $model['model'] ?? '',
            'manufacturer_name' => $manufacturer['name'],
        ]);
    }
}

// Filters
$fuelFilter = strtolower(trim($_GET['fuel'] ?? ''));
if ($fuelFilter !== '') {
    $models = array_values(array_filter($models, static function ($row) use ($fuelFilter) {
        $fuels = $row['fuel_types'] ?? [];
        return in_array($fuelFilter, array_map('strtolower', (array) $fuels), true);
    }));
    $allVariants = array_values(array_filter($allVariants, static function ($row) use ($fuelFilter) {
        $fuel = strtolower($row['fuel_type'] ?? '');
        return $fuel === $fuelFilter;
    }));
}

$sort = strtolower(trim($_GET['sort'] ?? ''));
if ($sort !== '') {
    usort($models, static function ($a, $b) use ($sort) {
        $priceA = (float) ($a['price_range']['min'] ?? 0);
        $priceB = (float) ($b['price_range']['min'] ?? 0);
        $yearA = (int) ($a['launch_year'] ?? 0);
        $yearB = (int) ($b['launch_year'] ?? 0);
        $powerA = (float) ($a['variants'][0]['horsepower'] ?? 0);
        $powerB = (float) ($b['variants'][0]['horsepower'] ?? 0);
        return match ($sort) {
            'price' => $priceA <=> $priceB,
            'year' => $yearB <=> $yearA,
            'power' => $powerB <=> $powerA,
            default => strcmp($a['model'] ?? '', $b['model'] ?? ''),
        };
    });
}

$fuelChips = [];
foreach ($models as $m) {
    foreach ((array) ($m['fuel_types'] ?? []) as $fuel) {
        if (!in_array($fuel, $fuelChips, true)) {
            $fuelChips[] = $fuel;
        }
    }
}

$modelCount = count($models);
?>

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft">Brand</p>
            <h1><?= e($manufacturer['name']) ?> models</h1>
            <p>Explore every model from <?= e($manufacturer['name']) ?> with detailed specs and pricing.</p>
            <div class="stat-row" style="margin-top: 20px;">
                <div class="stat">
                    <p class="muted">Models</p>
                    <strong><?= e((string) $modelCount) ?></strong>
                </div>
                <?php if (!empty($manufacturer['country'])): ?>
                    <div class="stat">
                        <p class="muted">Country</p>
                        <strong><?= e($manufacturer['country']) ?></strong>
                    </div>
                <?php endif; ?>
            </div>
            <div class="pill-row">
                <a class="pill" href="brand.php?manufacturer_id=<?= (int) $manufacturer['id'] ?>">All</a>
                <?php foreach ($fuelChips as $fuel): ?>
                    <a class="pill" href="brand.php?manufacturer_id=<?= (int) $manufacturer['id'] ?>&fuel=<?= urlencode($fuel) ?>">Fuel: <?= e($fuel) ?></a>
                <?php endforeach; ?>
            </div>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="tabs">
            <button class="tab-btn active" data-tab="models">Models</button>
            <button class="tab-btn" data-tab="variants">Variants</button>
            <button class="tab-btn" data-tab="about">About</button>
        </div>

        <div class="tab-content active" id="models">
            <div class="section-header">
                <div>
                    <p class="muted">Models</p>
                    <h2><?= e((string) $modelCount) ?> models found</h2>
                </div>
                <div class="card" style="padding:12px; display:flex; gap:8px; align-items:center;">
                    <label class="muted">Sort</label>
                    <select onchange="location.href='brand.php?manufacturer_id=<?= (int) $manufacturer['id'] ?>&sort='+this.value" aria-label="Sort models">
                        <option value="">Name</option>
                        <option value="price" <?= $sort === 'price' ? 'selected' : '' ?>>Price (low to high)</option>
                        <option value="year" <?= $sort === 'year' ? 'selected' : '' ?>>Launch year</option>
                        <option value="power" <?= $sort === 'power' ? 'selected' : '' ?>>Power</option>
                    </select>
                </div>
            </div>

            <?php if (empty($models)): ?>
                <?php render_empty_state('No models found', 'Try a different filter or brand'); ?>
            <?php else: ?>
                <div class="grid">
                    <?php foreach ($models as $model): ?>
                        <?php render_car_card($model); ?>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>

        <div class="tab-content" id="variants">
            <div class="section-header">
                <div>
                    <p class="muted">Variants</p>
                    <h2>All variants from <?= e($manufacturer['name']) ?> (<?= e((string) count($allVariants)) ?>)</h2>
                </div>
            </div>
            <?php if (empty($allVariants)): ?>
                <?php render_empty_state('No variants found', 'Try a different filter'); ?>
            <?php else: ?>
                <div class="table-container">
                    <table class="table table-spec">
                        <thead>
                        <tr>
                            <th>Model</th>
                            <th>Variant</th>
                            <th>Price</th>
                            <th>Engine</th>
                            <th>Transmission</th>
                            <th>Mileage</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($allVariants as $variant): ?>
                            <tr>
                                <td><?= e($variant['model_name']) ?></td>
                                <td><?= e($variant['variant_name'] ?? $variant['name'] ?? '') ?></td>
                                <td><?= e(format_price((float) ($variant['ex_showroom_price'] ?? 0))) ?></td>
                                <td><?= e($variant['engine_displacement_cc'] ?? '') ?> cc</td>
                                <td><?= e($variant['transmission'] ?? '') ?></td>
                                <td><?= e($variant['mileage_city_kmpl'] ?? $variant['mileage_kmpl'] ?? '') ?> kmpl</td>
                                <td>
                                    <a class="btn btn-outline btn-sm" href="variant.php?variant_id=<?= (int) ($variant['id'] ?? 0) ?>">View</a>
                                    <button class="btn btn-outline btn-sm" type="button" data-compare-add="<?= e($variant['id']) ?>" data-compare-label="<?= e($variant['manufacturer_name'] . ' ' . $variant['model_name'] . ' ' . ($variant['variant_name'] ?? $variant['name'] ?? '')) ?>">Compare</button>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
        </div>

        <div class="tab-content" id="about">
            <div class="section-header">
                <div>
                    <p class="muted">About</p>
                    <h2>About <?= e($manufacturer['name']) ?></h2>
                </div>
            </div>
            <div class="card">
                <p>Information about <?= e($manufacturer['name']) ?> coming soon...</p>
                <?php if (!empty($manufacturer['country'])): ?>
                    <p><strong>Country:</strong> <?= e($manufacturer['country']) ?></p>
                <?php endif; ?>
            </div>
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
})();
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
