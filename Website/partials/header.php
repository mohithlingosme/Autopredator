<?php
declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/../includes/helpers.php';

$pageTitle = $pageTitle ?? 'Autopredator | Predictive Automation';
$pageDescription = $pageDescription ?? 'Predictive fleet automation for proactive maintenance, compliance, and cost control.';
$bodyClass = $bodyClass ?? '';
$platformUrl = $platformUrl ?? '../Car Research web (DriveMatrix)/index.html';
$currentPath = basename(parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH) ?: 'index.php');
$scriptName = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '');
$siteBase = $siteBase ?? (preg_match('#(.*?/Website)#', $scriptName, $matches) ? $matches[1] : '');
$siteBase = rtrim($siteBase, '/');
if ($siteBase === '') {
    $siteBase = '/';
}
$baseHref = rtrim($siteBase, '/') ?: '/';
$currentUrl = ($baseHref === '/' ? '' : $baseHref) . ($currentPath ?: 'index.php');
$ogTitle = $pageTitle;
$ogDescription = $pageDescription;
$ogImage = $ogImage ?? 'assets/img/mock-dashboard.svg';
$ogUrl = $ogUrl ?? $currentUrl;
$navItems = [
    [
        'label' => 'Home',
        'href' => 'index.php',
        'matches' => ['index.php'],
    ],
    [
        'label' => 'Solutions',
        'href' => 'solutions.php',
        'matches' => [
            'solutions.php',
            'individuals.php',
            'fleet-owners.php',
            'dealers-and-brokers.php',
            'banks-and-insurers.php',
        ],
    ],
    [
        'label' => 'Product Suite / Apps',
        'href' => 'product-suite.php',
        'matches' => [
            'product-suite.php',
            'fleet-pro.php',
            'automart.php',
            'finance-desk.php',
            'ev-center.php',
        ],
    ],
    [
        'label' => 'For Fleets',
        'href' => 'for-fleets.php',
        'matches' => ['for-fleets.php'],
    ],
    [
        'label' => 'For Individuals',
        'href' => 'for-individuals.php',
        'matches' => ['for-individuals.php'],
    ],
    [
        'label' => 'For Partners',
        'href' => 'for-partners.php',
        'matches' => ['for-partners.php'],
    ],
    [
        'label' => 'Resources / Blog',
        'href' => 'resources.php',
        'matches' => ['resources.php', 'blog-list.php', 'blog-post.php'],
    ],
    [
        'label' => 'About',
        'href' => 'about.php',
        'matches' => ['about.php'],
    ],
    [
        'label' => 'Contact / Request Demo',
        'href' => 'contact.php#demo',
        'matches' => ['contact.php', 'contact-submit.php', 'thank-you.php'],
    ],
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= escape_html($pageTitle); ?></title>
  <meta name="description" content="<?= escape_html($pageDescription); ?>">
  <?php if ($baseHref !== ''): ?>
    <base href="<?= escape_html($baseHref); ?>/">
  <?php endif; ?>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/global.css">
  <link rel="stylesheet" href="assets/css/styles.css">
  <link rel="stylesheet" href="assets/css/components.css">
  <script defer src="assets/js/main.js"></script>
  <meta property="og:title" content="<?= escape_html($ogTitle); ?>">
  <meta property="og:description" content="<?= escape_html($ogDescription); ?>">
  <meta property="og:image" content="<?= escape_html($ogImage); ?>">
  <meta property="og:url" content="<?= escape_html($ogUrl); ?>">
  <!-- Google Analytics placeholder; replace GA_MEASUREMENT_ID -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'GA_MEASUREMENT_ID');
  </script>
</head>
<body class="<?= escape_html(trim($bodyClass)); ?>">
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
          <?php foreach ($navItems as $item): ?>
            <?php
              $isActive = in_array($currentPath, $item['matches'], true);
              $linkClass = $isActive ? 'is-active' : '';
            ?>
            <a class="<?= escape_html($linkClass); ?>" href="<?= escape_html($item['href']); ?>"><?= escape_html($item['label']); ?></a>
          <?php endforeach; ?>
          <a href="login.php">Login</a>
        </div>
      </nav>
      <div class="nav-actions">
        <a class="btn btn-secondary" data-cta="nav-launch-beta" href="<?= escape_html($platformUrl); ?>" target="_blank" rel="noopener">Launch Beta</a>
        <a class="btn btn-primary" data-cta="nav-book-demo" href="contact.php#demo">Book a demo</a>
      </div>
    </div>
  </header>
  <main>
