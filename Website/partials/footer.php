  </main>
  <footer class="footer">
    <div class="container footer-inner">
      <div class="footer-brand">
        <div class="logo">
          <span class="logo-mark">A</span><span class="logo-text">Autopredator</span>
        </div>
        <p class="text-small">Predictive automation that keeps your operation one step ahead.</p>
      </div>
      <div class="footer-columns">
        <div>
          <h4>Quick links</h4>
          <ul class="footer-list">
            <li><a href="solutions.php">Solutions</a></li>
            <li><a href="industries.php">Industries</a></li>
            <li><a href="how-it-works.php">How it works</a></li>
            <li><a href="resources.php">Resources</a></li>
          </ul>
        </div>
        <div>
          <h4>Company</h4>
          <ul class="footer-list">
            <li><a href="about.php">About</a></li>
            <li><a href="pricing.php">Pricing</a></li>
            <li><a href="contact.php">Contact</a></li>
            <li><a href="login.php">Login</a></li>
          </ul>
        </div>
        <div>
          <h4>Contact</h4>
          <ul class="footer-list">
            <li><a href="mailto:hello@autopredator.com">hello@autopredator.com</a></li>
            <li class="social-row">
              <a href="#" aria-label="LinkedIn">in</a>
              <a href="#" aria-label="Twitter / X">x</a>
              <a href="#" aria-label="YouTube">yt</a>
            </li>
          </ul>
        </div>
        <div>
          <h4>Get early access</h4>
          <form class="form footer-newsletter" data-newsletter-form action="api/api-newsletter.php" method="post">
            <label class="text-small" for="newsletter-email">Email</label>
            <div class="form-row">
              <input class="input" type="email" id="newsletter-email" name="email" placeholder="you@company.com" required>
              <button class="btn btn-primary" type="submit" data-cta="newsletter-submit">Notify me</button>
            </div>
            <p class="text-small muted form-status" aria-live="polite"></p>
          </form>
        </div>
      </div>
    </div>
    <div class="footer-bottom">
      <div class="container footer-bottom-inner">
        <span class="text-small">&copy; <?= date('Y'); ?> Autopredator. All rights reserved.</span>
      </div>
    </div>
  </footer>
</body>
</html>
