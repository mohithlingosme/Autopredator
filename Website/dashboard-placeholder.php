<?php
declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

$pageTitle = "Dashboard | Autopredator";
$pageDescription = "Dashboard placeholder for Autopredator.";
include 'includes/header.php';
?>
<section class="section">
  <div class="container surface stack">
    <div class="section-heading">
      <div class="tagline">Portal</div>
      <h1>Autopredator Portal coming soon</h1>
      <p class="muted">Your personalized dashboards and workflows will live here. For now, use the main site for resources and contact.</p>
    </div>
    <div class="hero-actions">
      <a class="btn btn-primary" href="index.php">Back to website</a>
      <a class="btn btn-ghost" href="logout.php">Logout</a>
    </div>
  </div>
</section>
<?php include 'includes/footer.php'; ?>
