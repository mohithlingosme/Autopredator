<?php
declare(strict_types=1);

require_once '../../includes/bootstrap.php';
require_once '../../app/Services/BillingService.php';

use App\Services\BillingService;

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit;
}

// Rate limiting: 100 requests per hour per IP
$rateLimiter = new RateLimiter();
$clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
if (!$rateLimiter->check($clientIP, 'webhook', 100, 3600)) {
    http_response_code(429);
    echo json_encode(['error' => 'Rate limit exceeded']);
    exit;
}

// Get raw payload
$payload = file_get_contents('php://input');
$signature = $_SERVER['HTTP_X_RAZORPAY_SIGNATURE'] ?? '';
$webhookSecret = getenv('RAZORPAY_WEBHOOK_SECRET') ?: 'your_webhook_secret_here';

try {
    $billingService = new BillingService(getDBConnection());

    // Verify webhook signature
    if (!$billingService->verifyWebhookSignature($payload, $signature, $webhookSecret)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid signature']);
        exit;
    }

    $webhookData = json_decode($payload, true);

    // Handle different event types
    switch ($webhookData['event']) {
        case 'payment.captured':
            $billingService->handlePaymentSuccess($webhookData);
            break;

        case 'payment.failed':
            // Handle failed payment
            break;

        case 'subscription.cancelled':
            // Handle subscription cancellation
            break;

        default:
            // Log unknown events
            break;
    }

    // Log webhook event
    $stmt = getDBConnection()->prepare("
        INSERT INTO audit_events (event_type, event_data, ip_address)
        VALUES ('webhook_received', ?, ?)
    ");
    $stmt->execute([json_encode($webhookData), $_SERVER['REMOTE_ADDR'] ?? '']);

    http_response_code(200);
    echo json_encode(['status' => 'ok']);

} catch (Exception $e) {
    error_log('Webhook error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
