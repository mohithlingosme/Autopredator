<?php
$pageTitle = "Contact | Autopredator";
$pageDescription = "Contact Autopredator for demos, pricing, and support for your fleet.";
include 'includes/header.php';
?>
<section class="section" id="demo">
  <div class="container stack surface">
    <div class="section-heading">
      <div class="tagline">Contact</div>
      <h1>Tell us about your fleet</h1>
      <p class="muted">We’ll tailor a walkthrough to your data, workflows, and goals.</p>
    </div>
    <form class="form" id="contact-form" action="contact-submit.php" method="post" novalidate>
      <div class="form-row">
        <div>
          <label for="name">Name</label>
          <input class="input" type="text" id="name" name="name" placeholder="Your name" required>
        </div>
        <div>
          <label for="email">Email</label>
          <input class="input" type="email" id="email" name="email" placeholder="you@company.com" required>
        </div>
      </div>
      <div class="form-row">
        <div>
          <label for="phone">Phone</label>
          <input class="input" type="tel" id="phone" name="phone" placeholder="+1 555 123 4567">
        </div>
        <div>
          <label for="company">Company</label>
          <input class="input" type="text" id="company" name="company" placeholder="Company name">
        </div>
      </div>
      <div class="form-row">
        <div>
          <label for="fleet_size">Fleet size</label>
          <input class="input" type="text" id="fleet_size" name="fleet_size" placeholder="e.g. 120 vehicles">
        </div>
      </div>
      <div>
        <label for="message">Message</label>
        <textarea class="input" id="message" name="message" rows="4" placeholder="How can we help?" required></textarea>
      </div>
      <button class="btn btn-primary" type="submit">Submit</button>
      <div class="form-errors" id="contact-errors"></div>
    </form>
  </div>
</section>
<?php include 'includes/footer.php'; ?>
