<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/auth.php';

$page_title = $page_title ?? 'Autopredator - Car Research Platform';
$page_description = $page_description ?? 'Discover cars, compare variants, and find the right model for you on Autopredator.';
$current_user = auth_current_user();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($page_title) ?></title>
    <meta name="description" content="<?= e($page_description) ?>">
    <link rel="icon" href="favicon.ico">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<header class="site-header">
    <div class="container nav-container">
        <div class="logo">
            <a href="index.php" aria-label="Autopredator home">Autopredator</a>
        </div>
        <button class="nav-toggle" aria-label="Toggle navigation">
            <span></span><span></span><span></span>
        </button>
        <div class="nav-search">
            <form action="search.php" method="get" class="search-form" id="header-search-form">
                <input type="search" name="q" aria-label="Search cars" placeholder="Search by brand, model or keyword" value="<?= e(get_query('q')) ?>">
                <button type="submit" class="btn btn-primary">Search</button>
            </form>
        </div>
        <nav class="nav-links">
            <a href="index.php">Home</a>
            <a href="brand.php">Brands</a>
            <a href="compare.php">Compare</a>
            <a href="my_garage.php">My Garage</a>
            <?php if ($current_user): ?>
                <span class="nav-user">Hi, <?= e($current_user['name'] ?? 'User') ?></span>
                <a href="logout.php">Logout</a>
            <?php else: ?>
                <a href="login.php">Login</a>
                <a href="register.php">Register</a>
            <?php endif; ?>
        </nav>
    </div>
</header>
<main class="page-content">
