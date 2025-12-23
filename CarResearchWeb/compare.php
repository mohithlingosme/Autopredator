<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$ids = [];
if (!empty($_GET['ids'])) {
    $ids = array_filter(array_map('trim', explode(',', (string) $_GET['ids'])));
}

$ids = array_slice(array_values(array_unique($ids)), 0, 4);

$variants = [];
foreach ($ids as $id) {
    $variant = repo()->getVariantByKey($id);
    if ($variant === null) {
        continue;
    }
    $variants[$id] = [
        'info' => $variant,
        'specs' => repo()->getSpecsForVariant($id),
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
        return isset($variant['info']['price_numeric'])
            ? format_price((float) $variant['info']['price_numeric'])
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

function best_value_index(array $variants, string $attr): ?int
{
    $values = [];
    foreach ($variants as $id => $variant) {
        $val = spec_value($variant, $attr);
        if (is_numeric($val)) {
            $values[$id] = (float) $val;
        }
    }
    if (empty($values)) {
        return null;
    }
    if ($attr === 'mileage_city_kmpl' || $attr === 'mileage_highway_kmpl') {
        // higher is better
        $best = max($values);
    } elseif ($attr === 'price') {
        // lower is better
        $best = min($values);
    } else {
        // for others, higher is better (power, torque, etc.)
        $best = max($values);
    }
    foreach ($values as $id => $val) {
        if ($val == $best) {
            return array_search($id, array_keys($variants));
        }
    }
    return null;
}

function build_remove_url(string $removeKey): string
{
    $ids = array_filter(array_map('trim', explode(',', (string) ($_GET['ids'] ?? ''))));
    $ids = array_values(array_diff($ids, [$removeKey]));

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
                <input type="search" name="q" data-search-input placeholder="Search more variants to add" aria-label="Search variants">
                <div class="search-suggestions" data-search-suggestions hidden></div>
                <button class="btn btn-primary" type="submit">Find variants</button>
            </form>
            <script type="application/json" id="search-suggestions"><?= json_encode($suggestions, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?></script>
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
                                <strong><?= e($v['info']['name'] ?? 'Variant') ?></strong><br>
                                <span class="muted"><?= e(($v['info']['brand'] ?? '') . ' ' . ($v['info']['model'] ?? '')) ?></span><br>
                                <?php if (isset($v['info']['price_numeric'])): ?>
                                    <span class="muted"><?= format_price((float) $v['info']['price_numeric']) ?></span>
                                <?php endif; ?>
                                <div style="margin-top:8px; display:flex; gap:6px; flex-wrap:wrap;">
                                    <?php if (!empty($v['info']['fuel_type'])): ?><span class="badge badge-success"><?= e($v['info']['fuel_type']) ?></span><?php endif; ?>
                                    <?php if (!empty($v['info']['transmission'])): ?><span class="badge badge-warning"><?= e($v['info']['transmission']) ?></span><?php endif; ?>
                                </div>
                                <div style="margin-top:8px;">
                                    <a class="btn btn-outline btn-sm" href="variant.php?variant_id=<?= (int) $id ?>">Open</a>
                                    <a class="btn btn-ghost btn-sm" href="<?= e(build_remove_url($id)) ?>" data-remove-key="<?= e($id) ?>">Remove</a>
                                </div>
                            </th>
                        <?php endforeach; ?>
                    </tr>
                    </thead>
                    <tbody>
                    <?php foreach ($attributes as $key => $label): ?>
                        <?php $mask = difference_mask($variants, $key); ?>
                        <?php $bestIndex = best_value_index($variants, $key); ?>
                        <tr>
                            <th><?= e($label) ?></th>
                            <?php foreach ($variants as $id => $v): ?>
                                <?php $val = spec_value($v, $key); ?>
                                <td class="<?= !empty($mask[$id]) ? 'highlight' : '' ?>"><?= e($val !== '' ? $val : '�') ?></td>
                            <?php endforeach; ?>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Persistence
    const urlParams = new URLSearchParams(window.location.search);
    const ids = urlParams.get('ids');
    if (!ids) {
        const stored = localStorage.getItem('compare_variants');
        if (stored) {
            const storedIds = JSON.parse(stored);
            if (storedIds.length > 0) {
                window.location.href = 'compare.php?ids=' + storedIds.join(',');
            }
        }
    } else {
        localStorage.setItem('compare_variants', JSON.stringify(ids.split(',')));
    }

    // Show differences only
    const checkbox = document.getElementById('show-differences-only');
    if (checkbox) {
        checkbox.addEventListener('change', function() {
            const rows = document.querySelectorAll('.compare-table tbody tr');
            rows.forEach(row => {
                const cells = Array.from(row.querySelectorAll('td'));
                const values = cells.map(cell => cell.textContent.trim());
                const unique = [...new Set(values)];
                if (this.checked && unique.length === 1) {
                    row.style.display = 'none';
                } else {
                    row.style.display = '';
                }
            });
        });
    }

    // Clear All function
    window.clearAll = function() {
        localStorage.removeItem('compare_variants');
        window.location.href = 'compare.php';
    };

    // Inline search to add variants
    document.addEventListener('click', function(e) {
        if (e.target.closest('.search-suggestions a')) {
            e.preventDefault();
            const href = e.target.closest('a').href;
            const url = new URL(href);
            const variantId = url.searchParams.get('variant_id');
            if (variantId) {
                const currentIds = new URLSearchParams(window.location.search).get('ids') || '';
                const ids = currentIds ? currentIds.split(',') : [];
                if (!ids.includes(variantId) && ids.length < 4) {
                    ids.push(variantId);
                    window.location.href = 'compare.php?ids=' + ids.join(',');
                }
            }
        }
    });
});
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
