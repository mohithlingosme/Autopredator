<?php
declare(strict_types=1);

$page_title = 'Contact Autopredator';
$page_description = 'Get in touch with the Autopredator team.';

require_once __DIR__ . '/includes/header.php';
?>

<section class="hero hero-small">
    <div class="container">
        <h1>Contact Us</h1>
        <p>Questions or feedback? Drop us a note.</p>
    </div>
</section>

<section class="section container">
    <div class="card" style="max-width: 640px; margin: 0 auto;">
        <h2>Send a Message</h2>
        <form method="post" action="contact.php" class="auth-form">
            <label>
                Name
                <input type="text" name="name" required>
            </label>
            <label>
                Email
                <input type="email" name="email" required>
            </label>
            <label>
                Message
                <textarea name="message" rows="4" required></textarea>
            </label>
            <button class="btn btn-primary" type="submit">Submit</button>
        </form>
        <?php if ($_SERVER['REQUEST_METHOD'] === 'POST'): ?>
            <div class="alert alert-success">Thanks! We received your message.</div>
        <?php endif; ?>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
