<?php $loginError = $loginError ?? false; ?>
<section class="section">
  <div class="container auth-wrapper">
    <div class="card auth-card stack">
      <div class="section-heading">
        <div class="tagline">Portal access</div>
        <h1>Login</h1>
        <p class="muted">Secure access to your Autopredator portal.</p>
      </div>
      <?php if ($loginError): ?>
        <div class="alert alert-error">
          <div>Invalid email or password.</div>
        </div>
      <?php endif; ?>
      <form class="form" id="login-form" action="auth-process.php" method="post" novalidate>
        <div>
          <label for="email">Email</label>
          <input class="input" type="email" id="email" name="email" placeholder="you@company.com" required>
        </div>
        <div>
          <label for="password">Password</label>
          <input class="input" type="password" id="password" name="password" placeholder="********" required>
        </div>
        <button class="btn btn-primary" type="submit">Sign in</button>
        <div class="form-errors" id="login-errors"></div>
      </form>
    </div>
  </div>
</section>
