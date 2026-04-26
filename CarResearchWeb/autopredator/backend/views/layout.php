<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/helpers.php';

if (!function_exists('render_layout_start')) {
    /**
     * Render the document start with navbar.
     */
    function render_layout_start(string $pageTitle, string $pageDescription = '', array $options = []): void
    {
        $pageDescription = $pageDescription !== '' ? $pageDescription : 'Discover and compare cars on Autopredator.';
        $bodyClass = $options['body_class'] ?? '';
        $suggestions = $options['suggestions'] ?? [];
        ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($pageTitle) ?></title>
    <meta name="description" content="<?= e($pageDescription) ?>">
    <link rel="icon" href="favicon.ico">
    <link rel="stylesheet" href="assets/css/app.css">
    <link rel="stylesheet" href="assets/css/components.css">
</head>
<body class="<?= e($bodyClass) ?>">
<div class="page-shell">
    <?php include __DIR__ . '/partials/navbar.php'; ?>
    <main class="page-content" id="main-content">
        <!-- Recently Viewed Section (only on home page) -->
        <?php if (basename($_SERVER['PHP_SELF']) === 'index.php'): ?>
            <section class="section">
                <div class="container">
                    <div data-recently-viewed></div>
                </div>
            </section>
        <?php endif; ?>
<?php if ($suggestions !== []): ?>
    <script type="application/json" id="search-suggestions"><?= json_encode($suggestions, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?></script>
<?php endif; ?>
<?php
    }
}

if (!function_exists('render_layout_end')) {
    /**
     * Close the document and render footer.
     */
    function render_layout_end(): void
    {
        ?>
    </main>
    <?php include __DIR__ . '/partials/footer.php'; ?>
</div>
<script src="assets/js/app.js" defer></script>
<script src="assets/js/compare.js"></script>
<script src="assets/js/favorites.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    function updateBadge(selector, storageKey) {
        const count = JSON.parse(localStorage.getItem(storageKey) || '[]').length;
        const badge = document.querySelector(selector);
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline';
        } else {
            badge.style.display = 'none';
        }
    }

    // Update badges on load
    updateBadge('[data-compare-count]', 'compare_variants');
    updateBadge('[data-shortlist-count]', 'shortlist_variants');

    // Listen for storage changes
    window.addEventListener('storage', function(e) {
        if (e.key === 'compare_variants') {
            updateBadge('[data-compare-count]', 'compare_variants');
        } else if (e.key === 'shortlist_variants') {
            updateBadge('[data-shortlist-count]', 'shortlist_variants');
        }
    });

    // Custom event for same-tab updates
    window.addEventListener('updateBadges', function() {
        updateBadge('[data-compare-count]', 'compare_variants');
        updateBadge('[data-shortlist-count]', 'shortlist_variants');
    });

    // Mobile nav toggle
    const navToggle = document.querySelector('[data-nav-toggle]');
    const navLinks = document.querySelector('[data-nav-links]');
    if (navToggle && navLinks) {
        navToggle.addEventListener('click', function() {
            navLinks.classList.toggle('is-open');
            document.body.classList.toggle('nav-open');
        });
    }
});
</script>
</body>
</html>
<?php
    }
}
