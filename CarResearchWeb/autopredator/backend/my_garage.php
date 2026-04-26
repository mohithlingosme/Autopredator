<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/header.php';

auth_require_login('/login.php?redirect=/my_garage.php');

$favourites = fav_get_list();
$items = [];
foreach ($favourites as $fid) {
    $variant = get_variant_by_id($fid);
    if ($variant) {
        $items[] = $variant;
    }
}
?>

<section class="section container">
    <div class="section-header">
        <h1>My Garage</h1>
    </div>

    <?php if (empty($items)): ?>
        <article class="card">
            <p>No favourites yet. Add cars to your garage from variant pages.</p>
        </article>
    <?php else: ?>
        <div class="grid grid-3">
            <?php foreach ($items as $variant): ?>
                <article class="card">
                    <h3><?= e($variant['manufacturer_name'] ?? '') ?> <?= e($variant['model_name'] ?? '') ?> <?= e($variant['variant_name'] ?? '') ?></h3>
                    <div class="badge-row">
                        <?php if (!empty($variant['fuel_type'])): ?>
                            <span class="badge badge-success"><?= e($variant['fuel_type']) ?></span>
                        <?php endif; ?>
                        <?php if (!empty($variant['transmission'])): ?>
                            <span class="badge badge-warning"><?= e($variant['transmission']) ?></span>
                        <?php endif; ?>
                    </div>
                    <?php if (isset($variant['ex_showroom_price'])): ?>
                        <p class="price"><?= format_price((float) $variant['ex_showroom_price']) ?></p>
                    <?php endif; ?>
                    <form method="post" action="/favourites.php" class="garage-actions">
                        <input type="hidden" name="variant_id" value="<?= (int) $variant['id'] ?>">
                        <input type="hidden" name="action" value="remove">
                        <div class="badge-row">
                            <button class="btn btn-outline" type="submit">Remove</button>
                            <a class="btn btn-primary" href="variant.php?variant_id=<?= (int) $variant['id'] ?>">View</a>
                        </div>
                    </form>
                </article>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
