<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/audit_log.php';

if (!ADMIN_ENABLED) {
    http_response_code(404);
    echo 'Admin panel is disabled.';
    exit;
}

$message = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';

    $error = auth_login($email, $password);
    if ($error) {
        $message = $error;
        audit_log('admin_login_failed', ['email' => $email, 'ip' => $_SERVER['REMOTE_ADDR'] ?? '']);
    } else {
        // Check if user has admin role or higher
        if (auth_has_role('Admin')) {
            audit_log('admin_login_success', ['email' => $email, 'ip' => $_SERVER['REMOTE_ADDR'] ?? '']);
            header('Location: ' . ADMIN_BASE_URL);
            exit;
        } else {
            $message = 'Access denied. Admin privileges required.';
            audit_log('admin_login_denied', ['email' => $email, 'reason' => 'insufficient_privileges', 'ip' => $_SERVER['REMOTE_ADDR'] ?? '']);
            auth_logout();
        }
    }
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Autopredator</title>
    <link rel="stylesheet" href="/assets/css/admin.css">
</head>
<body class="admin-body">
    <div class="admin-container">
        <div class="admin-sidebar">
            <div class="admin-sidebar-header">
                <h2>Autopredator Admin</h2>
            </div>
            <nav class="admin-nav">
                <ul>
                    <li><a href="/" class="nav-link">← Back to Site</a></li>
                </ul>
            </nav>
        </div>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="breadcrumbs">
                    Admin / Login
                </div>
            </div>
            <div class="admin-content">
                <h1>Admin Login</h1>
                <?php if ($message): ?>
                    <div class="alert alert-error"><?php echo htmlspecialchars($message); ?></div>
                <?php endif; ?>
                <form method="post" action="">
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password:</label>
                        <input type="password" id="password" name="password" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Login</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
