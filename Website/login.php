<?php
declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/includes/helpers.php';

$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($email === '' || $password === '') {
        $errors[] = 'Email and password are required.';
    } else {
        $pdo = get_db_connection();
        if ($pdo) {
            try {
                $stmt = $pdo->prepare('SELECT id, name, email, password_hash, role FROM users WHERE email = :email LIMIT 1');
                $stmt->execute(['email' => $email]);
                $user = $stmt->fetch();
                if ($user && password_verify($password, $user['password_hash'])) {
                    $_SESSION['user_id'] = (int)$user['id'];
                    $_SESSION['user_name'] = $user['name'] ?? '';
                    $_SESSION['user_role'] = $user['role'] ?? '';
                    header('Location: dashboard-placeholder.php');
                    exit;
                } else {
                    $errors[] = 'Invalid email or password.';
                }
            } catch (PDOException $e) {
                error_log('Login failed: ' . $e->getMessage());
                $errors[] = 'An error occurred. Please try again.';
            }
        } else {
            $errors[] = 'Database connection unavailable.';
        }
    }
}

$pageTitle = "Login | Autopredator";
$pageDescription = "Login to Autopredator.";
include 'includes/header.php';
?>
<section class="section">
  <div class="container auth-wrapper">
    <div class="card auth-card stack">
      <div class="section-heading">
        <div class="tagline">Portal access</div>
        <h1>Login</h1>
        <p class="muted">Secure access to your Autopredator portal.</p>
      </div>
      <?php if (!empty($errors)): ?>
        <div class="alert alert-error">
          <?php foreach ($errors as $error): ?>
            <div><?= escape_html($error); ?></div>
          <?php endforeach; ?>
        </div>
      <?php endif; ?>
      <form class="form" id="login-form" method="post" novalidate>
        <div>
          <label for="email">Email</label>
          <input class="input" type="email" id="email" name="email" placeholder="you@company.com" required>
        </div>
        <div>
          <label for="password">Password</label>
          <input class="input" type="password" id="password" name="password" placeholder="••••••••" required>
        </div>
        <button class="btn btn-primary" type="submit">Sign in</button>
        <div class="form-errors" id="login-errors"></div>
      </form>
    </div>
  </div>
</section>
<?php include 'includes/footer.php'; ?>
