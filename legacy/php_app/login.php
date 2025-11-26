<?php
session_start();
include 'includes/functions.php';

// Generate CSRF token
$csrf_token = generate_csrf_token();
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login | Autopredator</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body {
      background-color: #f5f5f5;
      font-family: 'Segoe UI', sans-serif;
    }
    .auth-container {
      max-width: 400px;
      margin: 80px auto;
      padding: 30px;
      background: #fff;
      border-radius: 10px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .toggle-link {
      text-decoration: underline;
      color: #007bff;
      cursor: pointer;
    }
  </style>
</head>
<body>

<div class="auth-container">
  <h3 class="text-center mb-4" id="form-title">Login</h3>

  <?php if (isset($_SESSION['auth_error'])): ?>
    <div class="alert alert-danger"><?= $_SESSION['auth_error']; unset($_SESSION['auth_error']); ?></div>
  <?php endif; ?>

  <!-- 🔐 LOGIN FORM -->
    <form id="login-form" action="modules/auth-process.php" method="POST">
    <input type="hidden" name="action" value="login">
    <input type="hidden" name="csrf_token" value="<?= $csrf_token ?>">
    <div class="mb-3">
      <label>Email or Username</label>
      <input type="text" name="username" class="form-control" required>
    </div>
    <div class="mb-3">
      <label>Password</label>
      <input type="password" name="password" class="form-control" required>
    </div>
    <button type="submit" class="btn btn-primary w-100">Login</button>
    <p class="mt-3 text-center">Don't have an account? <span class="toggle-link" onclick="toggleForm()">Register</span></p>
  </form>

  <!-- 📝 REGISTER FORM -->
    <form id="register-form" action="modules/auth-process.php" method="POST" style="display: none;">
    <input type="hidden" name="action" value="register">
    <input type="hidden" name="csrf_token" value="<?= $csrf_token ?>">
    <div class="mb-3">
      <label>Full Name</label>
      <input type="text" name="name" class="form-control" required>
    </div>
    <div class="mb-3">
      <label>Email</label>
      <input type="email" name="email" class="form-control" required>
    </div>
    <div class="mb-3">
      <label>Password</label>
      <input type="password" name="password" class="form-control" required minlength="6">
    </div>
    <button type="submit" class="btn btn-success w-100">Create Account</button>
    <p class="mt-3 text-center">Already have an account? <span class="toggle-link" onclick="toggleForm()">Login</span></p>
  </form>
</div>

<script>
  function toggleForm() {
    const loginForm = document.getElementById("login-form");
    const registerForm = document.getElementById("register-form");
    const title = document.getElementById("form-title");

    if (loginForm.style.display === "none") {
      loginForm.style.display = "block";
      registerForm.style.display = "none";
      title.innerText = "Login";
    } else {
      loginForm.style.display = "none";
      registerForm.style.display = "block";
      title.innerText = "Register";
    }
  }
</script>

</body>
</html>
