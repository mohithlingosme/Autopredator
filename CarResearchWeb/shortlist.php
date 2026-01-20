<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/views/partials/car_card.php';
require_once __DIR__ . '/views/partials/empty_state.php';

// Noindex for shortlist page
$page_noindex = true;

$shortlistedSlugs = [];
try {
    $response = file_get_contents('http://' . $_SERVER['HTTP_HOST'] . '/api/shortlist');
    $data = json_decode($response, true);
    if ($data['ok']) {
        $shortlistedSlugs = $data['data'];
    }
} catch (Exception $e) {
    // Fallback to empty
}

$shortlistedVariants = [];
if (!empty($shortlistedSlugs)) {
    foreach ($shortlistedSlugs as $slug) {
        $variantName = ucwords(str_replace('-', ' ', $slug));
        $variants = repo()->search(['variant' => $variantName]);
        if ($variants) {
            $shortlistedVariants[] = $variants[0];
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
                            <button class="btn btn-outline btn-sm" type="button" data-shortlist-remove="<?= e(strtolower(str_replace(' ', '-', $variant['variant']))) ?>" data-shortlist-label="<?= e($variant['manufacturer_name'] . ' ' . $variant['model_name'] . ' ' . $variant['variant_name']) ?>">Remove</button>
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
        btn.addEventListener('click', async function() {
            const variantSlug = this.getAttribute('data-shortlist-remove');
            try {
                const response = await fetch('/api/shortlist/remove', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ variant_slug: variantSlug })
                });
                const data = await response.json();
                if (data.ok) {
                    // Reload page to reflect changes
                    location.reload();
                } else {
                    alert('Failed to remove from shortlist');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred');
            }
        });
    });
});
</script>

<?php
require_once __DIR__ . '/includes/footer.php';
?>
