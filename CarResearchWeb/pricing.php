<?php
declare(strict_types=1);

require_once 'includes/bootstrap.php';
require_once 'app/Services/BillingService.php';

use App\Services\BillingService;

// Get all active plans
$stmt = getDBConnection()->prepare("
    SELECT * FROM plans
    WHERE is_active = 1
    ORDER BY sort_order ASC
");
$stmt->execute();
$plans = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Get current user's subscription if logged in
$currentPlan = null;
if (isset($_SESSION['user_id'])) {
    $billingService = new BillingService(getDBConnection());
    $stmt = getDBConnection()->prepare("SELECT org_id FROM users WHERE id = ?");
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && $user['org_id']) {
        $subscription = $billingService->getSubscriptionStatus($user['org_id']);
        if ($subscription) {
            $currentPlan = $subscription['plan_id'];
        }
    }
}

$pageTitle = 'Pricing - Autopredator';
require_once 'views/layout.php';
?>

<div class="container mx-auto px-4 py-8">
    <div class="text-center mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">Choose Your Plan</h1>
        <p class="text-xl text-gray-600">Find the perfect plan for your car research needs</p>
    </div>

    <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-8 max-w-7xl mx-auto">
        <?php foreach ($plans as $plan): ?>
        <div class="bg-white rounded-lg shadow-lg p-6 <?php echo $currentPlan == $plan['id'] ? 'ring-2 ring-blue-500' : ''; ?>">
            <div class="text-center">
                <h3 class="text-2xl font-bold text-gray-900 mb-2"><?php echo htmlspecialchars($plan['name']); ?></h3>
                <div class="text-4xl font-bold text-blue-600 mb-4">
                    ₹<?php echo number_format($plan['price_monthly']); ?>
                    <span class="text-lg text-gray-500">/month</span>
                </div>
                <?php if ($plan['price_yearly']): ?>
                <div class="text-sm text-gray-600 mb-4">
                    or ₹<?php echo number_format($plan['price_yearly']); ?>/year (save <?php echo round((1 - $plan['price_yearly'] / ($plan['price_monthly'] * 12)) * 100); ?>%)
                </div>
                <?php endif; ?>
            </div>

            <p class="text-gray-600 mb-6"><?php echo htmlspecialchars($plan['description']); ?></p>

            <ul class="space-y-3 mb-8">
                <?php
                $features = json_decode($plan['features'], true) ?: [];
                $featureLabels = [
                    'search' => 'Basic search',
                    'compare' => 'Compare vehicles',
                    'favorites' => 'Save favorites',
                    'export' => 'Export data',
                    'ai_content' => 'AI-powered insights',
                    'analytics' => 'Advanced analytics',
                    'all' => 'All features included'
                ];

                foreach ($features as $feature) {
                    $label = $featureLabels[$feature] ?? ucfirst(str_replace('_', ' ', $feature));
                    echo "<li class='flex items-center'><i class='fas fa-check text-green-500 mr-2'></i>{$label}</li>";
                }
                ?>
            </ul>

            <?php if ($currentPlan == $plan['id']): ?>
                <button class="w-full bg-gray-400 text-white py-3 px-4 rounded-lg cursor-not-allowed" disabled>
                    Current Plan
                </button>
            <?php else: ?>
                <button class="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 px-4 rounded-lg transition duration-200 subscribe-btn"
                        data-plan-id="<?php echo $plan['id']; ?>">
                    <?php echo $plan['price_monthly'] > 0 ? 'Subscribe Now' : 'Get Started'; ?>
                </button>
            <?php endif; ?>

            <?php if ($plan['trial_days'] > 0): ?>
                <p class="text-sm text-gray-500 mt-2"><?php echo $plan['trial_days']; ?> days free trial</p>
            <?php endif; ?>
        </div>
        <?php endforeach; ?>
    </div>

    <!-- FAQ Section -->
    <div class="max-w-4xl mx-auto mt-16">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-8">Frequently Asked Questions</h2>
        <div class="space-y-6">
            <div class="bg-white rounded-lg shadow p-6">
                <h3 class="text-lg font-semibold mb-2">Can I change my plan anytime?</h3>
                <p class="text-gray-600">Yes, you can upgrade or downgrade your plan at any time. Changes take effect immediately.</p>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <h3 class="text-lg font-semibold mb-2">Is there a free trial?</h3>
                <p class="text-gray-600">Most paid plans come with a free trial period. Check individual plan details above.</p>
            </div>
            <div class="bg-white rounded-lg shadow p-6">
                <h3 class="text-lg font-semibold mb-2">What payment methods do you accept?</h3>
                <p class="text-gray-600">We accept all major credit/debit cards and UPI payments through our secure Razorpay integration.</p>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.subscribe-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const planId = this.dataset.planId;
            // Redirect to checkout or show modal
            window.location.href = `/checkout?plan=${planId}`;
        });
    });
});
</script>

<?php require_once 'views/partials/footer.php'; ?>
</body>
</html>
