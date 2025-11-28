<?php
declare(strict_types=1);

$page_title = 'Terms of Use';
$page_description = 'Autopredator terms of use.';

require_once __DIR__ . '/includes/header.php';
?>

<section class="hero hero-small">
    <div class="container">
        <h1>Terms of Use</h1>
        <p>Guidelines for using the Autopredator platform.</p>
    </div>
</section>

<section class="section container">
    <div class="card">
        <h2>Usage</h2>
        <p>This demo provides vehicle research data. Use it for personal reference; verify pricing and specs with official sources before purchase.</p>
        <h3>Content</h3>
        <ul>
            <li>Data accuracy is best-effort based on the provided database.</li>
            <li>No commercial warranty is provided.</li>
        </ul>
        <h3>Accounts</h3>
        <p>Session-based authentication is provided; keep your credentials secure. We may clear sessions during development.</p>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
