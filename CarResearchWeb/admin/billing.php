<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../app/Services/BillingService.php';

use App\Services\BillingService;

// Check if admin is enabled
if (!ADMIN_ENABLED) {
    http_response_code(404);
    echo 'Admin panel is disabled.';
    exit;
}

// Check if user is logged in and has admin role
if (!auth_is_logged_in() || !auth_has_role('admin')) {
    header('Location: ' . ADMIN_BASE_URL . '/login.php');
    exit;
}

$pageTitle = 'Billing Dashboard';
$activeTab = 'billing';

require_once 'includes/header.php';

$billingService = new BillingService(getDBConnection());

// Get billing statistics
$stats = [
    'total_revenue' => 0,
    'active_subscriptions' => 0,
    'trial_subscriptions' => 0,
    'failed_payments' => 0,
    'recent_payments' => [],
    'subscriptions_by_plan' => []
];

// Calculate total revenue
$stmt = getDBConnection()->prepare("
    SELECT SUM(amount) as total
    FROM payments
    WHERE status = 'completed'
");
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);
$stats['total_revenue'] = $result['total'] ?? 0;

// Count active subscriptions
$stmt = getDBConnection()->prepare("
    SELECT COUNT(*) as count
    FROM subscriptions
    WHERE status = 'active'
");
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);
$stats['active_subscriptions'] = $result['count'] ?? 0;

// Count trial subscriptions
$stmt = getDBConnection()->prepare("
    SELECT COUNT(*) as count
    FROM subscriptions
    WHERE status = 'trial'
");
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);
$stats['trial_subscriptions'] = $result['count'] ?? 0;

// Count failed payments
$stmt = getDBConnection()->prepare("
    SELECT COUNT(*) as count
    FROM payments
    WHERE status = 'failed'
");
$stmt->execute();
$result = $stmt->fetch(PDO::FETCH_ASSOC);
$stats['failed_payments'] = $result['count'] ?? 0;

// Get recent payments
$stmt = getDBConnection()->prepare("
    SELECT p.*, s.org_id, o.name as org_name
    FROM payments p
    JOIN subscriptions s ON p.subscription_id = s.id
    LEFT JOIN organizations o ON s.org_id = o.id
    ORDER BY p.created_at DESC
    LIMIT 10
");
$stmt->execute();
$stats['recent_payments'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Get subscriptions by plan
$stmt = getDBConnection()->prepare("
    SELECT pl.name, COUNT(s.id) as count
    FROM plans pl
    LEFT JOIN subscriptions s ON pl.id = s.plan_id AND s.status IN ('active', 'trial')
    GROUP BY pl.id, pl.name
    ORDER BY pl.sort_order
");
$stmt->execute();
$stats['subscriptions_by_plan'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="admin-content">
    <div class="admin-header">
        <h1>Billing Dashboard</h1>
        <p>Monitor subscription and payment activity</p>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-content">
                <h3>Total Revenue</h3>
                <p class="stat-value">₹<?php echo number_format($stats['total_revenue'], 2); ?></p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
                <h3>Active Subscriptions</h3>
                <p class="stat-value"><?php echo $stats['active_subscriptions']; ?></p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">🧪</div>
            <div class="stat-content">
                <h3>Trial Subscriptions</h3>
                <p class="stat-value"><?php echo $stats['trial_subscriptions']; ?></p>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">❌</div>
            <div class="stat-content">
                <h3>Failed Payments</h3>
                <p class="stat-value"><?php echo $stats['failed_payments']; ?></p>
            </div>
        </div>
    </div>

    <div class="dashboard-grid">
        <!-- Subscriptions by Plan -->
        <div class="dashboard-card">
            <h3>Subscriptions by Plan</h3>
            <div class="chart-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Plan</th>
                            <th>Active Subscriptions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($stats['subscriptions_by_plan'] as $plan): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($plan['name']); ?></td>
                            <td><?php echo $plan['count']; ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Recent Payments -->
        <div class="dashboard-card">
            <h3>Recent Payments</h3>
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Organization</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($stats['recent_payments'] as $payment): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($payment['org_name'] ?? 'N/A'); ?></td>
                            <td>₹<?php echo number_format($payment['amount'], 2); ?></td>
                            <td>
                                <span class="status-badge status-<?php echo $payment['status']; ?>">
                                    <?php echo ucfirst($payment['status']); ?>
                                </span>
                            </td>
                            <td><?php echo date('M j, Y', strtotime($payment['created_at'])); ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="dashboard-card">
        <h3>Quick Actions</h3>
        <div class="action-buttons">
            <a href="<?php echo ADMIN_BASE_URL; ?>/subscriptions.php" class="btn btn-primary">
                Manage Subscriptions
            </a>
            <a href="<?php echo ADMIN_BASE_URL; ?>/payments.php" class="btn btn-secondary">
                View All Payments
            </a>
            <a href="<?php echo ADMIN_BASE_URL; ?>/invoices.php" class="btn btn-secondary">
                Generate Invoices
            </a>
        </div>
    </div>
</div>

<style>
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
}

.stat-card {
    background: white;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    display: flex;
    align-items: center;
    gap: 1rem;
}

.stat-icon {
    font-size: 2rem;
}

.stat-content h3 {
    margin: 0;
    font-size: 0.9rem;
    color: #666;
}

.stat-value {
    margin: 0.5rem 0 0 0;
    font-size: 1.8rem;
    font-weight: bold;
    color: #333;
}

.dashboard-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
    margin-bottom: 2rem;
}

.dashboard-card {
    background: white;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.dashboard-card h3 {
    margin-top: 0;
    margin-bottom: 1rem;
    color: #333;
}

.data-table {
    width: 100%;
    border-collapse: collapse;
}

.data-table th,
.data-table td {
    padding: 0.75rem;
    text-align: left;
    border-bottom: 1px solid #eee;
}

.data-table th {
    background: #f8f9fa;
    font-weight: 600;
    color: #555;
}

.status-badge {
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.8rem;
    font-weight: 500;
}

.status-completed { background: #d4edda; color: #155724; }
.status-pending { background: #fff3cd; color: #856404; }
.status-failed { background: #f8d7da; color: #721c24; }

.action-buttons {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
}

.btn {
    padding: 0.75rem 1.5rem;
    border-radius: 4px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.2s;
}

.btn-primary {
    background: #007bff;
    color: white;
}

.btn-primary:hover {
    background: #0056b3;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}

.btn-secondary:hover {
    background: #545b62;
}

@media (max-width: 768px) {
    .dashboard-grid {
        grid-template-columns: 1fr;
    }

    .stats-grid {
        grid-template-columns: 1fr;
    }

    .action-buttons {
        flex-direction: column;
    }
}
</style>

<?php require_once 'includes/footer.php'; ?>
