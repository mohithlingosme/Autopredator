<?php
declare(strict_types=1);

$page_title = 'About Autopredator';
$page_description = 'Learn about the Autopredator car research platform.';

require_once __DIR__ . '/includes/header.php';
?>

<section class="hero hero-small">
    <div class="container">
        <h1>About Autopredator</h1>
        <p>Data-driven research for Indian car buyers, built for clarity and speed.</p>
    </div>
</section>

<section class="section container">
    <div class="card">
        <h2>Our Mission</h2>
        <p>We collect, organize, and present manufacturer, model, variant, specs, and pricing data so you can compare cars without clutter.</p>
    </div>
    <div class="grid grid-3" style="margin-top: 1.5rem;">
        <article class="card">
            <h3>Trusted Data</h3>
            <p>Variants, specs, and price history tied directly to the database schema.</p>
        </article>
        <article class="card">
            <h3>Fast Compare</h3>
            <p>Compare up to four variants with specs and price deltas highlighted.</p>
        </article>
        <article class="card">
            <h3>Responsive</h3>
            <p>Optimized layouts for desktop and mobile with a focused red/black theme.</p>
        </article>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
