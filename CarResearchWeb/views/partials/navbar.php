<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';
$current_user = $current_user ?? null;
$query = get_query('q');
?>
<header class="site-header">
    <div class="container nav-container">
        <div class="logo">
            <a href="index.php" aria-label="Autopredator home">Autopredator</a>
        </div>
        <button class="nav-toggle" aria-label="Toggle navigation" data-nav-toggle>
            <span></span><span></span><span></span>
        </button>
        <div class="nav-search">
            <?php include __DIR__ . '/search_bar.php'; ?>
        </div>
        <nav class="nav-links" data-nav-links>
            <a href="index.php" class="nav-link">Home</a>
            <a href="brand.php" class="nav-link">Brands</a>
            <a href="search.php" class="nav-link">Search</a>
            <a href="compare.php" class="nav-link">Compare</a>
            <?php if ($current_user): ?>
                <span class="nav-user">Hi, <?= e($current_user['name'] ?? 'User') ?></span>
                <a href="logout.php" class="nav-link">Logout</a>
            <?php else: ?>
                <a href="login.php" class="nav-link">Login</a>
                <a href="register.php" class="nav-link">Register</a>
            <?php endif; ?>
        </nav>
    </div>
</header>
