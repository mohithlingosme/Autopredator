<?php
$pageTitle = "Resources | Autopredator";
$pageDescription = "Autopredator resources, guides, and collateral.";
include 'includes/header.php';
?>
<section class="section">
  <div class="container stack">
    <div class="section-heading">
      <div class="tagline">Resources</div>
      <h1>Guides, blogs, and updates</h1>
      <p class="muted">Get the latest thinking on predictive fleet automation.</p>
    </div>

    <div class="surface stack">
      <h3>Guides (PDF)</h3>
      <ul class="list">
        <li><span class="bullet"></span><a class="text-emphasis" href="#">Fleet Automation Playbook (PDF)</a></li>
        <li><span class="bullet"></span><a class="text-emphasis" href="#">Compliance Checklist for Mixed Fleets (PDF)</a></li>
        <li><span class="bullet"></span><a class="text-emphasis" href="#">Predictive Maintenance Starter Kit (PDF)</a></li>
      </ul>
    </div>

    <div class="surface stack">
      <h3>Latest blog posts</h3>
      <div class="grid grid-3">
        <div class="card card-contrast card-underline">
          <h4>Why reactive maintenance is costing you</h4>
          <p class="muted">How to quantify downtime and fuel waste from delayed alerts.</p>
          <a class="text-emphasis" href="blog-post.php?id=1">Read more →</a>
        </div>
        <div class="card card-contrast card-underline">
          <h4>Designing driver-first safety programs</h4>
          <p class="muted">Coaching and compliance without adding operational friction.</p>
          <a class="text-emphasis" href="blog-post.php?id=2">Read more →</a>
        </div>
        <div class="card card-contrast card-underline">
          <h4>Building a single source of truth</h4>
          <p class="muted">Data architecture lessons from multi-OEM fleets.</p>
          <a class="text-emphasis" href="blog-post.php?id=3">Read more →</a>
        </div>
        <div class="card card-contrast card-underline">
          <h4>From alerts to automation</h4>
          <p class="muted">Routing tasks to the right teams without spreadsheets.</p>
          <a class="text-emphasis" href="blog-post.php?id=4">Read more →</a>
        </div>
        <div class="card card-contrast card-underline">
          <h4>How to prove ROI on fleet data</h4>
          <p class="muted">Build the business case for predictive automation.</p>
          <a class="text-emphasis" href="blog-post.php?id=5">Read more →</a>
        </div>
      </div>
    </div>

    <div class="surface stack">
      <h3>Newsletter</h3>
      <p class="muted">Get monthly insights on predictive automation.</p>
      <form class="form">
        <div class="form-row">
          <div>
            <label for="news-name">Name</label>
            <input class="input" type="text" id="news-name" name="name" placeholder="Your name">
          </div>
          <div>
            <label for="news-email">Email</label>
            <input class="input" type="email" id="news-email" name="email" placeholder="you@company.com" required>
          </div>
        </div>
        <button class="btn btn-primary" type="submit">Subscribe</button>
      </form>
    </div>
  </div>
</section>
<?php include 'includes/footer.php'; ?>
