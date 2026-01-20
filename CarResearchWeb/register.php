<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/header.php';

auth_session_start();

$error = '';
$redirect = $_GET['redirect'] ?? 'index.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $err = auth_register($name, $email, $password);
    if ($err === null) {
        header('Location: ' . $redirect);
        exit;
    }
    $error = $err;
}
?>

<section class="section container">
    <div class="card auth-card">
        <h1>Register</h1>
        <?php if ($error): ?>
            <div class="alert alert-error"><?= e($error) ?></div>
        <?php endif; ?>
        <form method="post" action="register.php?redirect=<?= urlencode($redirect) ?>" class="auth-form">
            <label>
                Name
                <input type="text" name="name" required>
            </label>
            <label>
                Email
                <input type="email" name="email" required>
            </label>
            <label>
                Password
                <input type="password" name="password" required>
            </label>
            <button class="btn btn-primary" type="submit">Create account</button>
        </form>
        <p>Already have an account? <a href="login.php">Login</a></p>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
