<?php
session_start();
require_once 'config_users.php'; // ✅ DB connection with $userConn
require_once 'includes/functions.php'; // ✅ Include functions for CSRF and RBAC

$action = $_POST['action'] ?? null;

// Validate CSRF token
if (!isset($_POST['csrf_token']) || !validate_csrf_token($_POST['csrf_token'])) {
    $_SESSION['auth_error'] = "Invalid request. Please try again.";
    header("Location: login.php");
    exit;
}

// Validate action
if (!in_array($action, ['login', 'register'])) {
    $_SESSION['auth_error'] = "Invalid request.";
    header("Location: login.php");
    exit;
}

// === 🔐 REGISTER USER ===
if ($action === 'register') {
    $name     = trim($_POST['name']);
    $email    = trim($_POST['email']);
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);

    // ✅ Check if email already exists
    $check = $userConn->prepare("SELECT id FROM users WHERE email = ?");
    $check->bind_param("s", $email);
    $check->execute();
    $check->store_result();

    if ($check->num_rows > 0) {
        $_SESSION['auth_error'] = "Email is already registered!";
        header("Location: login.php");
        exit;
    }

    // ✅ Insert new user
    $stmt = $userConn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $name, $email, $password);

    if ($stmt->execute()) {
        $_SESSION['user'] = $name;
        header("Location: index.php");
        exit;
    } else {
        $_SESSION['auth_error'] = "Registration failed. Please try again.";
        header("Location: login.php");
        exit;
    }
}

// === 🔐 LOGIN USER ===
if ($action === 'login') {
    $username = trim($_POST['username']);
    $password = $_POST['password'];

    // ✅ Find user by email or username
    $stmt = $userConn->prepare("SELECT id, name, password, user_type FROM users WHERE email = ? OR name = ?");
    $stmt->bind_param("ss", $username, $username);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0) {
        $_SESSION['auth_error'] = "User not found.";
        header("Location: login.php");
        exit;
    }

    $stmt->bind_result($id, $name, $hashedPassword, $userType);
    $stmt->fetch();

    // ✅ Check password
    if (password_verify($password, $hashedPassword)) {
        // Regenerate session ID for security
        session_regenerate_id(true);
        $_SESSION['user'] = $name;
        $_SESSION['user_id'] = $id;
        $_SESSION['user_type'] = $userType;
        header("Location: index.php");
        exit;
    } else {
        $_SESSION['auth_error'] = "Incorrect password.";
        header("Location: login.php");
        exit;
    }
}

// ✅ Default fallback (should never reach here)
$_SESSION['auth_error'] = "Unexpected error.";
header("Location: login.php");
exit;
// File moved to modules/auth-process.php
