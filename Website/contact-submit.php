<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: contact.php');
    exit;
}

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$company = trim($_POST['company'] ?? '');
$fleetSize = trim($_POST['fleet_size'] ?? '');
$message = trim($_POST['message'] ?? '');

$errors = [];
if ($name === '') {
    $errors[] = 'Name is required.';
}
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'A valid email is required.';
}
if ($message === '') {
    $errors[] = 'Message is required.';
}

if (count($errors) === 0) {
    $saved = create_lead([
        'name' => $name,
        'email' => $email,
        'phone' => $phone,
        'company' => $company,
        'fleet_size' => $fleetSize,
        'message' => $message,
        'source' => 'contact-form',
    ]);

    if ($saved) {
        header('Location: thank-you.php');
        exit;
    }

    $errors[] = 'We could not save your request. Please try again.';
}

$pageTitle = "Contact Submitted | Autopredator";
$pageDescription = "Contact form submission status.";
include 'includes/header.php';
?>
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
    <?php endif; ?>
  </div>
</section>
<?php include 'includes/footer.php'; ?>
