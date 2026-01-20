<?php
declare(strict_types=1);


require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/audit_log.php';
// Check if admin is enabled
if (!ADMIN_ENABLED) {
    http_response_code(404);
    echo 'Admin panel is disabled.';
    exit;
}

// Check if user is logged in and has admin role
if (!auth_is_logged_in() || !auth_has_role('Admin')) {
    header('Location: ' . ADMIN_BASE_URL . '/login.php');
    exit;
}

// Placeholder data for dashboard
$drafts = 5;
$review_queue = 12;
$published_this_week = 8;
$pending_updates = 3;

$alerts = [
    'Missing citations in 3 articles',
    'Stale prices in 7 variants',
    'Broken links in 2 blog posts',
    'Failed imports from 1 data source'
];

$recent_activity = array_map(function($log) {
    return $log['timestamp'] . ': ' . $log['action'];
}, audit_get_recent_logs(4));

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Autopredator</title>
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
                    <li><a href="<?php echo ADMIN_BASE_URL; ?>" class="nav-link active">Dashboard</a></li>
                    <li><a href="/" class="nav-link">← Back to Site</a></li>
                </ul>
            </nav>
        </div>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="breadcrumbs">
                    Admin / Dashboard
                </div>
                <div class="admin-actions">
                    <a href="<?php echo ADMIN_BASE_URL; ?>/logout.php" class="btn btn-secondary">Logout</a>
                </div>
            </div>
            <div class="admin-content">
                <h1>Admin Dashboard</h1>

                <!-- Overview Cards -->
                <div class="overview-cards">
                    <div class="card">
                        <h3>Drafts</h3>
                        <div class="card-value"><?php echo $drafts; ?></div>
                    </div>
                    <div class="card">
                        <h3>Review Queue</h3>
                        <div class="card-value"><?php echo $review_queue; ?></div>
                    </div>
                    <div class="card">
                        <h3>Published This Week</h3>
                        <div class="card-value"><?php echo $published_this_week; ?></div>
                    </div>
                    <div class="card">
                        <h3>Pending Updates</h3>
                        <div class="card-value"><?php echo $pending_updates; ?></div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="quick-actions">
                    <h2>Quick Actions</h2>
                    <div class="action-buttons">
                        <a href="#" class="btn btn-primary">New Article</a>
                        <a href="#" class="btn btn-primary">Add Variant</a>
                        <a href="#" class="btn btn-primary">Update Price</a>
                    </div>
                </div>

                <!-- Alerts -->
                <div class="alerts-section">
                    <h2>Alerts</h2>
                    <ul class="alerts-list">
                        <?php foreach ($alerts as $alert): ?>
                            <li class="alert-item"><?php echo htmlspecialchars($alert); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>

                <!-- Recent Activity -->
                <div class="recent-activity">
                    <h2>Recent Activity</h2>
                    <ul class="activity-list">
                        <?php foreach ($recent_activity as $activity): ?>
                            <li class="activity-item"><?php echo htmlspecialchars($activity); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
