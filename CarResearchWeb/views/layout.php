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
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/app.css">
</head>
<body class="<?= e($bodyClass) ?>">
<div class="page-shell">
    <?php include __DIR__ . '/partials/navbar.php'; ?>
    <main class="page-content" id="main-content">
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
</body>
</html>
<?php
    }
}
