<?php
declare(strict_types=1);

session_start();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/repository.php';

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

<section class="section container">
    <div class="section-header">
        <h1>Compare Cars</h1>
    </div>

    <?php if (empty($variants)): ?>
        <article class="card">
            <p>No variants selected. Add cars to compare from the model or search pages.</p>
        </article>
    <?php else: ?>
        <div class="compare-header">
            <?php foreach ($variants as $id => $v): ?>
                <div class="compare-card">
                    <div class="badge badge-info">Variant</div>
                    <h3><?= e($v['info']['variant_name'] ?? 'Variant') ?></h3>
                    <p><?= e(($v['info']['manufacturer_name'] ?? '') . ' ' . ($v['info']['model_name'] ?? '')) ?></p>
                    <?php if (isset($v['info']['ex_showroom_price'])): ?>
                        <p class="price"><?= format_price((float) $v['info']['ex_showroom_price']) ?></p>
                    <?php endif; ?>
                    <div class="badge-row">
                        <?php if (!empty($v['info']['fuel_type'])): ?>
                            <span class="badge badge-success"><?= e($v['info']['fuel_type']) ?></span>
                        <?php endif; ?>
                        <?php if (!empty($v['info']['transmission'])): ?>
                            <span class="badge badge-warning"><?= e($v['info']['transmission']) ?></span>
                        <?php endif; ?>
                    </div>
                    <div class="compare-card-actions">
                        <a class="btn btn-outline" href="variant.php?variant_id=<?= (int) $id ?>">View</a>
                        <a class="btn btn-outline" href="<?= e(build_remove_url((int) $id)) ?>" aria-label="Remove from comparison">Remove</a>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <div class="card">
            <table class="table table-compare">
                <thead>
                <tr>
                    <th>Specs</th>
                    <?php foreach ($variants as $v): ?>
                        <th><?= e($v['info']['variant_name'] ?? 'Variant') ?></th>
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
                            <td class="<?= !empty($mask[$id]) ? 'highlight-diff' : '' ?>"><?= e($val) ?></td>
                        <?php endforeach; ?>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
