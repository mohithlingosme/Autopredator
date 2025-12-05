<?php $errors = $errors ?? []; ?>
<section class="section">
  <div class="container surface stack">
    <h1>Contact submission</h1>
    <?php if (!empty($errors)): ?>
      <p class="muted">We encountered some issues:</p>
      <ul class="list">
        <?php foreach ($errors as $error): ?>
          <li><span class="bullet"></span><span><?= escape_html($error); ?></span></li>
        <?php endforeach; ?>
      </ul>
      <div class="hero-actions">
        <a class="btn btn-primary" href="contact.php">Back to contact</a>
      </div>
    <?php else: ?>
      <p class="muted">Your request was processed.</p>
      <a class="text-emphasis" href="contact.php">Back to contact</a>
    <?php endif; ?>
  </div>
</section>
