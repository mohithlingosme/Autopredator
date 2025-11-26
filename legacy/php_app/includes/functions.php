<?php
// includes/functions.php - Utility functions for RBAC and security

// Function to check if user is logged in
function is_logged_in() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

// Function to check user role
function has_role($required_role) {
    if (!is_logged_in()) {
        return false;
    }
    $user_role = $_SESSION['user_type'] ?? 'Customer';
    return $user_role === $required_role;
}

// Function to check if user has any of the specified roles
function has_any_role($roles) {
    if (!is_logged_in()) {
        return false;
    }
    $user_role = $_SESSION['user_type'] ?? 'Customer';
    return in_array($user_role, $roles);
}

// Function to require login
function require_login() {
    if (!is_logged_in()) {
        header("Location: login.php");
        exit;
    }
}

// Function to require specific role
function require_role($role) {
    require_login();
    if (!has_role($role)) {
        $_SESSION['auth_error'] = "Access denied. Insufficient permissions.";
        header("Location: index.php");
        exit;
    }
}

// Function to generate CSRF token
function generate_csrf_token() {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

// Function to validate CSRF token
function validate_csrf_token($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}
?>
