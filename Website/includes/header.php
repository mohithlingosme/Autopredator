<?php
declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/helpers.php';

$pageTitle = $pageTitle ?? 'Autopredator | Predictive Automation';
$pageDescription = $pageDescription ?? 'Predictive automation platform for proactive threat hunting and operational efficiency.';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= escape_html($pageTitle); ?></title>
  <meta name="description" content="<?= escape_html($pageDescription); ?>">
  <link rel="stylesheet" href="assets/css/styles.css">
  <link rel="stylesheet" href="assets/css/components.css">
  <script defer src="assets/js/main.js"></script>
  <!-- Google Analytics placeholder; replace GA_MEASUREMENT_ID -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'GA_MEASUREMENT_ID');
  </script>
</head>
<body>
  <header class="nav">
    <div class="container nav-inner">
      <a class="logo" href="index.php" aria-label="Autopredator home">
        <span class="logo-mark">A</span><span class="logo-text">Autopredator</span>
      </a>
      <button class="nav-toggle" aria-expanded="false" aria-label="Toggle navigation">
        <span class="nav-toggle-bar"></span>
        <span class="nav-toggle-bar"></span>
        <span class="nav-toggle-bar"></span>
      </button>
      <nav aria-label="Primary">
        <div class="nav-links">
          <a href="index.php">Home</a>
          <a href="solutions.php">Solutions</a>
          <a href="industries.php">Industries</a>
          <a href="how-it-works.php">How it works</a>
          <a href="resources.php">Resources</a>
          <a href="blog-list.php">Blog</a>
          <a href="pricing.php">Pricing</a>
          <a href="about.php">About</a>
          <a href="contact.php">Contact</a>
          <a href="login.php">Login</a>
        </div>
      </nav>
      <div class="nav-actions">
        <a class="btn btn-primary" href="contact.php#demo">Book a demo</a>
      </div>
    </div>
  </header>
  <main>
