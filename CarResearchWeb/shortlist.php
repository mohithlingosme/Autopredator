<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/views/partials/car_card.php';
require_once __DIR__ . '/views/partials/empty_state.php';

$shortlistedIds = [];
if (isset($_GET['ids'])) {
    $shortlistedIds = array_filter(explode(',', $_GET['ids']));
} elseif (isset($_COOKIE['shortlist_variants'])) {
    $shortlistedIds = json_decode($_COOKIE['shortlist_variants'], true) ?? [];
}

$shortlistedVariants = [];
if (!empty($shortlistedIds)) {
    foreach ($shortlistedIds as $id) {
        $variant = get_variant_by_id((int) $id);
        if ($variant) {
            $shortlistedVariants[] = $variant;
        }
    }
}

$page_title = 'My Shortlist - Autopredator';
$page_description = 'Review your shortlisted car variants and compare them.';
?>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <p class="muted">Your selections</p>
                <h1>My Shortlist</h1>
                <p>Review and compare your favorite car variants.</p>
            </div>
            <?php if (!empty($shortlistedVariants)): ?>
                <a class="btn btn-primary" href="compare.php?ids=<?= implode(',', array_column($shortlistedVariants, 'id')) ?>">Compare Selected</a>
            <?php endif; ?>
        </div>

        <?php if (empty($shortlistedVariants)): ?>
            <?php render_empty_state('Your shortlist is empty', 'Start browsing cars and add variants to your shortlist.', 'Browse Cars', 'index.php'); ?>
        <?php else: ?>
            <div class="grid">
                <?php foreach ($shortlistedVariants as $variant): ?>
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
                            <button class="btn btn-outline btn-sm" type="button" data-shortlist-remove="<?= e($variant['id']) ?>" data-shortlist-label="<?= e($variant['manufacturer_name'] . ' ' . $variant['model_name'] . ' ' . $variant['variant_name']) ?>">Remove</button>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[data-shortlist-remove]').forEach(btn => {
        btn.addEventListener('click', function() {
            const variantId = this.getAttribute('data-shortlist-remove');
            let shortlist = JSON.parse(localStorage.getItem('shortlist_variants') || '[]');
            shortlist = shortlist.filter(id => id !== variantId);
            localStorage.setItem('shortlist_variants', JSON.stringify(shortlist));
            // Dispatch custom event to update badges
            window.dispatchEvent(new Event('updateBadges'));
            // Reload page to reflect changes
            location.reload();
        });
    });
});
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
