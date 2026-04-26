<?php
declare(strict_types=1);


require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/audit_log.php';
require_once __DIR__ . '/../app/Support/GraphifyTrigger.php';

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

// ── Handle manual Graphify regeneration ──────────────────────
$graphifyMessage = null;
$graphifyMessageType = 'info'; // info | success | error

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'regenerate_graph') {
    if (!GraphifyTrigger::isEnabled()) {
        $graphifyMessage = 'Graphify auto-generation is disabled in config.';
        $graphifyMessageType = 'error';
    } elseif (!GraphifyTrigger::isBinaryAvailable()) {
        $graphifyMessage = 'Graphify binary not found. Install with: pip install graphifyy';
        $graphifyMessageType = 'error';
    } else {
        $result = GraphifyTrigger::run();
        $graphifyMessage = $result['message'] . ($result['details'] ? ' (' . $result['details'] . ')' : '');
        $graphifyMessageType = $result['success'] ? 'success' : 'error';
    }
}

$graphifyStatus = GraphifyTrigger::status();

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
    <style>
        .graphify-status { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 6px; }
        .graphify-status.enabled { background-color: #22c55e; }
        .graphify-status.disabled { background-color: #ef4444; }
        .graphify-status.unavailable { background-color: #f59e0b; }
        .alert-box { padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; }
        .alert-box.success { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .alert-box.error  { background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .alert-box.info   { background-color: #e0f2fe; color: #075985; border: 1px solid #bae6fd; }
    </style>
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

                <?php if ($graphifyMessage !== null): ?>
                    <div class="alert-box <?php echo htmlspecialchars($graphifyMessageType); ?>">
                        <?php echo htmlspecialchars($graphifyMessage); ?>
                    </div>
                <?php endif; ?>

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
                    <!-- Graphify Status Card -->
                    <div class="card">
                        <h3>Graphify Status</h3>
                        <div style="font-size: 0.9rem; margin-top: 8px;">
                            <?php if ($graphifyStatus['enabled'] && $graphifyStatus['available']): ?>
                                <span class="graphify-status enabled"></span> Auto-generate ON
                            <?php elseif (!$graphifyStatus['enabled']): ?>
                                <span class="graphify-status disabled"></span> Auto-generate OFF
                            <?php else: ?>
                                <span class="graphify-status unavailable"></span> Binary missing
                            <?php endif; ?>
                            <?php if ($graphifyStatus['last_run']): ?>
                                <br><small>Last run: <?php echo htmlspecialchars($graphifyStatus['last_run']); ?></small>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="quick-actions">
                    <h2>Quick Actions</h2>
                    <div class="action-buttons">
                        <a href="#" class="btn btn-primary">New Article</a>
                        <a href="#" class="btn btn-primary">Add Variant</a>
                        <a href="#" class="btn btn-primary">Update Price</a>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="action" value="regenerate_graph">
                            <button type="submit" class="btn btn-primary" <?php echo (!$graphifyStatus['enabled'] || !$graphifyStatus['available']) ? 'disabled' : ''; ?>>
                                Regenerate Graphify
                            </button>
                        </form>
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

