<?php
declare(strict_types=1);

session_start();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/repository.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$ids = [];
if (!empty($_GET['ids'])) {
    $ids = array_filter(array_map('intval', explode(',', (string) $_GET['ids'])));
} elseif (!empty($_SESSION['compare_variants']) && is_array($_SESSION['compare_variants'])) {
    $ids = array_map('intval', $_SESSION['compare_variants']);
}

$ids = array_slice(array_values(array_unique($ids)), 0, 4);
$_SESSION['compare_variants'] = $ids;

$variants = [];
foreach ($ids as $id) {
    $variant = get_variant_by_id($id);
    if ($variant === null) {
        continue;
    }
    $variants[$id] = [
        'info' => $variant,
        'specs' => get_specs_for_variant($id) ?? [],
    ];
}

$attributes = [
    'price' => 'Ex-Showroom Price',
    'fuel_type' => 'Fuel Type',
    'transmission' => 'Transmission',
    'engine_displacement_cc' => 'Engine (cc)',
    'max_power_bhp' => 'Max Power (bhp)',
    'max_torque_nm' => 'Max Torque (Nm)',
    'mileage_city_kmpl' => 'Mileage (City)',
    'mileage_highway_kmpl' => 'Mileage (Highway)',
    'seating_capacity' => 'Seating Capacity',
    'fuel_tank_capacity_ltr' => 'Fuel Tank (L)',
    'ground_clearance_mm' => 'Ground Clearance (mm)',
    'boot_space_ltr' => 'Boot Space (L)',
];

function spec_value(array $variant, string $key): string
{
    if ($key === 'price') {
        return isset($variant['info']['ex_showroom_price'])
            ? format_price((float) $variant['info']['ex_showroom_price'])
            : '';
    }

    if (array_key_exists($key, $variant['info'])) {
        return (string) $variant['info'][$key];
    }

    if (array_key_exists($key, $variant['specs'])) {
        return (string) $variant['specs'][$key];
    }

    return '';
}

function difference_mask(array $variants, string $attr): array
{
    $values = [];
    foreach ($variants as $id => $variant) {
        $values[$id] = spec_value($variant, $attr);
    }

    $unique = array_unique($values);
    $differs = count($unique) > 1;

    $mask = [];
    foreach ($values as $id => $value) {
        $mask[$id] = $differs && $value !== '';
    }

    return $mask;
}

function build_remove_url(int $removeId): string
{
    $ids = array_filter(array_map('intval', explode(',', (string) ($_GET['ids'] ?? ''))));
    $ids = array_values(array_diff($ids, [$removeId]));

    if (empty($ids)) {
        return 'compare.php';
    }

    return 'compare.php?ids=' . urlencode(implode(',', $ids));
}
?>

<section class="hero">
    <div class="container">
        <div class="hero-card">
            <p class="badge badge-soft">Compare</p>
            <h1>Compare up to 4 variants</h1>
            <p>Differences are highlighted so you can decide faster.</p>
            <form class="search-form" action="search.php" method="get">
                <input type="search" name="q" placeholder="Search more variants to add" aria-label="Search variants">
                <button class="btn btn-primary" type="submit">Find variants</button>
            </form>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <?php if (empty($variants)): ?>
            <?php render_empty_state('No variants selected', 'Add variants from search or model pages to compare', 'Browse cars', 'search.php'); ?>
        <?php else: ?>
            <div class="card compare-grid">
                <table class="compare-table">
                    <thead>
                    <tr>
                        <th>Specs</th>
                        <?php foreach ($variants as $id => $v): ?>
                            <th>
                                <p class="muted">Variant</p>
                                <strong><?= e($v['info']['variant_name'] ?? 'Variant') ?></strong><br>
                                <span class="muted"><?= e(($v['info']['manufacturer_name'] ?? '') . ' ' . ($v['info']['model_name'] ?? '')) ?></span><br>
                                <?php if (isset($v['info']['ex_showroom_price'])): ?>
                                    <span class="muted"><?= format_price((float) $v['info']['ex_showroom_price']) ?></span>
                                <?php endif; ?>
                                <div style="margin-top:8px; display:flex; gap:6px; flex-wrap:wrap;">
                                    <?php if (!empty($v['info']['fuel_type'])): ?><span class="badge badge-success"><?= e($v['info']['fuel_type']) ?></span><?php endif; ?>
                                    <?php if (!empty($v['info']['transmission'])): ?><span class="badge badge-warning"><?= e($v['info']['transmission']) ?></span><?php endif; ?>
                                </div>
                                <div style="margin-top:8px;">
                                    <a class="btn btn-outline btn-sm" href="variant.php?variant_id=<?= (int) $id ?>">Open</a>
                                    <a class="btn btn-ghost btn-sm" href="<?= e(build_remove_url((int) $id)) ?>">Remove</a>
                                </div>
                            </th>
                        <?php endforeach; ?>
                    </tr>
                    </thead>
                    <tbody>
                    <?php foreach ($attributes as $key => $label): ?>
                        <?php $mask = difference_mask($variants, $key); ?>
                        <tr>
                            <th><?= e($label) ?></th>
                            <?php foreach ($variants as $id => $v): ?>
                                <?php $val = spec_value($v, $key); ?>
                                <td class="<?= !empty($mask[$id]) ? 'highlight' : '' ?>"><?= e($val !== '' ? $val : '—') ?></td>
                            <?php endforeach; ?>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
