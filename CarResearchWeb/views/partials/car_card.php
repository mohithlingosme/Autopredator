<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';

/**
 * @param array<string, mixed> $car
 */
function render_car_card(array $car): void
{
    $title = $car['model'] ?? ($car['name'] ?? 'Model');
    $brand = $car['make'] ?? ($car['brand'] ?? '');
    $segment = $car['segment'] ?? '';
    $fuel = $car['fuel_types'][0] ?? ($car['fuel_type'] ?? '');
    $min = $car['price_range']['min'] ?? ($car['price_numeric'] ?? 0);
    $max = $car['price_range']['max'] ?? ($car['price_numeric'] ?? 0);
    $modelName = $car['model'] ?? $car['name'] ?? '';
    ?>
<article class="card car-card">
    <div class="card-top">
        <p class="muted"><?= e($brand) ?></p>
        <h3><?= e($title) ?></h3>
        <?php if ($segment !== ''): ?>
            <span class="badge badge-soft"><?= e($segment) ?></span>
        <?php endif; ?>
    </div>
    <div class="card-body">
        <div class="stat-row">
            <?php if ($min || $max): ?>
                <div class="stat">
                    <p class="muted">Price</p>
                    <strong><?= format_price((float) $min) ?><?php if ($max && $max !== $min): ?> - <?= format_price((float) $max) ?><?php endif; ?></strong>
                </div>
            <?php endif; ?>
            <?php if ($fuel): ?>
                <div class="stat">
                    <p class="muted">Fuel</p>
                    <strong><?= e(is_array($fuel) ? implode(', ', $fuel) : $fuel) ?></strong>
                </div>
            <?php endif; ?>
        </div>
    </div>
    <div class="card-footer">
        <a href="model.php?model_name=<?= urlencode($modelName) ?>" class="btn btn-primary">View Details</a>
        <button class="btn btn-outline" type="button" data-compare-add="<?= e($modelName) ?>" data-compare-label="<?= e($brand . ' ' . $title) ?>">Add to Compare</button>
    </div>
</article>
<?php
}
