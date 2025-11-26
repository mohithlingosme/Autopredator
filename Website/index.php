<?php
$pageTitle = "Autopredator | Predictive Automation";
$pageDescription = "Predictive fleet automation that reduces downtime, controls costs, and keeps every vehicle compliant.";
include 'includes/header.php';
?>

<section class="hero" id="hero">
  <div class="container hero-content">
    <div class="tagline">Predictive automation</div>
    <h1>Stay ahead of vehicle risk, costs, and compliance</h1>
    <p>Autopredator ingests your fleet, telematics, and maintenance data to predict failures, automate workflows, and keep every vehicle compliant.</p>
    <div class="hero-actions">
      <a class="btn btn-primary" href="contact.php#demo">Book a demo</a>
      <a class="btn btn-ghost" href="solutions.php">Explore solutions</a>
    </div>
  </div>
</section>

<section class="section" id="why">
  <div class="container stack">
    <div class="section-heading">
      <div class="tagline">Why vehicle management is broken</div>
      <h2>Reactive tools miss the early signals</h2>
      <p class="muted">Disconnected data, manual follow-ups, and delayed alerts keep fleets exposed. Autopredator fixes the gaps.</p>
    </div>
    <div class="grid grid-4">
      <div class="card card-contrast card-underline">
        <h3>Data silos</h3>
        <p>OEM, telematics, and shop data rarely align, delaying action on critical issues.</p>
      </div>
      <div class="card card-contrast card-underline">
        <h3>Manual triage</h3>
        <p>Teams chase spreadsheets instead of letting automation route tasks instantly.</p>
      </div>
      <div class="card card-contrast card-underline">
        <h3>Hidden costs</h3>
        <p>Fuel waste, downtime, and compliance penalties accumulate out of sight.</p>
      </div>
      <div class="card card-contrast card-underline">
        <h3>Slow alerts</h3>
        <p>Events surface too late to prevent breakdowns or SLA misses.</p>
      </div>
    </div>
  </div>
</section>

<section class="section" id="solutions">
  <div class="container stack">
    <div class="section-heading">
      <div class="tagline">Solutions</div>
      <h2>Built for proactive fleets</h2>
      <p class="muted">Four pillars that keep every vehicle predictable, compliant, and efficient.</p>
    </div>
    <div class="grid grid-4">
      <div class="card card-underline card-accent">
        <div class="card-icon">VM</div>
        <h3>Vehicle Management</h3>
        <p>Single source of truth for health, history, and open actions across assets.</p>
      </div>
      <div class="card card-underline card-accent">
        <div class="card-icon">FM</div>
        <h3>Fleet Management</h3>
        <p>Predictive alerts, work order routing, and escalations to keep wheels turning.</p>
      </div>
      <div class="card card-underline card-accent">
        <div class="card-icon">CA</div>
        <h3>Cost &amp; Analytics</h3>
        <p>Surface fuel anomalies, downtime trends, and parts spend variance instantly.</p>
      </div>
      <div class="card card-underline card-accent">
        <div class="card-icon">SC</div>
        <h3>Safety &amp; Compliance</h3>
        <p>Automated checks for inspections, licensing, DVIR, and high-risk behaviors.</p>
      </div>
    </div>
  </div>
</section>

<section class="section" id="industries">
  <div class="container stack">
    <div class="section-heading">
      <div class="tagline">Industries</div>
      <h2>Tailored for the fleets that move the world</h2>
      <p class="muted">From heavy equipment to delivery vans, Autopredator adapts to your operation.</p>
    </div>
    <div class="grid grid-4">
      <div class="card card-contrast card-underline">
        <h3>Logistics &amp; Fleets</h3>
        <p>Keep routes on time with predictive maintenance and driver safety signals.</p>
      </div>
      <div class="card card-contrast card-underline">
        <h3>Construction</h3>
        <p>Protect uptime for heavy equipment with condition-based interventions.</p>
      </div>
      <div class="card card-contrast card-underline">
        <h3>Agriculture</h3>
        <p>Monitor seasonal utilization, fuel efficiency, and critical parts health.</p>
      </div>
      <div class="card card-contrast card-underline">
        <h3>Corporate / Leasing</h3>
        <p>Control total cost of ownership while keeping drivers compliant and safe.</p>
      </div>
    </div>
  </div>
</section>

<section class="section" id="how-it-works">
  <div class="container stack">
    <div class="section-heading">
      <div class="tagline">How it works</div>
      <h2>Predict, automate, and prove the outcomes</h2>
    </div>
    <div class="grid grid-3 steps">
      <div class="step">
        <span class="step-number">1</span>
        <h3>Connect</h3>
        <p class="muted">Ingest telematics, maintenance, and ERP data with secure connectors.</p>
      </div>
      <div class="step">
        <span class="step-number">2</span>
        <h3>Automate</h3>
        <p class="muted">Trigger workflows, route alerts, and assign tasks automatically.</p>
      </div>
      <div class="step">
        <span class="step-number">3</span>
        <h3>Optimise</h3>
        <p class="muted">Track outcomes, costs, and compliance with live analytics.</p>
      </div>
    </div>
  </div>
</section>

<section class="section" id="contact">
  <div class="container stack surface">
    <div class="section-heading">
      <div class="tagline">Book time</div>
      <h2>See Autopredator in action</h2>
      <p class="muted">Tell us about your fleet and we’ll tailor a live walkthrough.</p>
    </div>
    <form class="form" id="lead-capture-form">
      <div class="form-row">
        <div>
          <label for="lead-name">Name</label>
          <input class="input" type="text" id="lead-name" name="name" placeholder="Your name" required>
        </div>
        <div>
          <label for="lead-email">Email</label>
          <input class="input" type="email" id="lead-email" name="email" placeholder="you@company.com" required>
        </div>
        <div>
          <label for="lead-company">Company</label>
          <input class="input" type="text" id="lead-company" name="company" placeholder="Company name">
        </div>
      </div>
      <button class="btn btn-primary" type="submit">Book a demo</button>
      <p class="text-small muted" id="lead-form-status"></p>
    </form>
  </div>
</section>

<script>
  const leadForm = document.getElementById('lead-capture-form');
  const leadStatus = document.getElementById('lead-form-status');
  if (leadForm) {
    leadForm.addEventListener('submit', function (e) {
      e.preventDefault();
      leadStatus.textContent = 'Thanks! We will reach out shortly.';
    });
  }
</script>

<?php include 'includes/footer.php'; ?>
