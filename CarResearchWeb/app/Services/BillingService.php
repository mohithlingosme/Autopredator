<?php
declare(strict_types=1);

namespace App\Services;

use PDO;

/**
 * Billing Service - Handles subscriptions, payments, and Razorpay integration
 */
class BillingService
{
    private PDO $db;
    private string $razorpayKeyId;
    private string $razorpayKeySecret;

    public function __construct(PDO $db)
    {
        $this->db = $db;
        $this->razorpayKeyId = getenv('RAZORPAY_KEY_ID') ?: '';
        $this->razorpayKeySecret = getenv('RAZORPAY_KEY_SECRET') ?: '';
    }

    /**
     * Create Razorpay order for subscription
     */
    public function createOrder(int $orgId, int $planId, int $quantity = 1): array
    {
        // Get plan details
        $stmt = $this->db->prepare("SELECT * FROM plans WHERE id = ?");
        $stmt->execute([$planId]);
        $plan = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$plan) {
            throw new \Exception('Plan not found');
        }

        $amount = (int)($plan['price_monthly'] * $quantity * 100); // Razorpay expects paisa

        // Create Razorpay order
        $orderData = [
            'receipt' => 'org_' . $orgId . '_' . time(),
            'amount' => $amount,
            'currency' => 'INR',
            'payment_capture' => 1
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'https://api.razorpay.com/v1/orders');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($orderData));
        curl_setopt($ch, CURLOPT_USERPWD, $this->razorpayKeyId . ':' . $this->razorpayKeySecret);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            throw new \Exception('Failed to create Razorpay order');
        }

        $order = json_decode($response, true);

        // Store order in database
        $stmt = $this->db->prepare("
            INSERT INTO payments (subscription_id, amount, currency, status, payment_method, external_id)
            VALUES (?, ?, 'INR', 'pending', 'razorpay', ?)
        ");
        $stmt->execute([null, $plan['price_monthly'] * $quantity, $order['id']]);

        return [
            'order_id' => $order['id'],
            'amount' => $amount,
            'currency' => 'INR',
            'key' => $this->razorpayKeyId
        ];
    }

    /**
     * Handle successful payment webhook
     */
    public function handlePaymentSuccess(array $webhookData): void
    {
        $paymentId = $webhookData['payment']['entity']['id'];
        $orderId = $webhookData['payment']['entity']['order_id'];
        $amount = $webhookData['payment']['entity']['amount'] / 100; // Convert from paisa

        // Update payment status
        $stmt = $this->db->prepare("
            UPDATE payments
            SET status = 'completed', paid_at = NOW(), updated_at = NOW()
            WHERE external_id = ?
        ");
        $stmt->execute([$paymentId]);

        // Create or update subscription
        $this->createOrUpdateSubscription($orderId, $amount);
    }

    /**
     * Create or update subscription after payment
     */
    private function createOrUpdateSubscription(string $orderId, float $amount): void
    {
        // Find payment and get org/plan details (simplified - you'd need to store this mapping)
        // This is a simplified implementation - in production, you'd store order metadata

        // For now, assume we have org_id and plan_id from somewhere
        // You'd typically store this in the order creation
    }

    /**
     * Get subscription status for org
     */
    public function getSubscriptionStatus(int $orgId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT s.*, p.name as plan_name, p.price_monthly
            FROM subscriptions s
            JOIN plans p ON s.plan_id = p.id
            WHERE s.org_id = ? AND s.status IN ('active', 'trial', 'past_due')
            ORDER BY s.created_at DESC
            LIMIT 1
        ");
        $stmt->execute([$orgId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Cancel subscription
     */
    public function cancelSubscription(int $subscriptionId): void
    {
        $stmt = $this->db->prepare("
            UPDATE subscriptions
            SET status = 'canceled', canceled_at = NOW(), updated_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$subscriptionId]);
    }

    /**
     * Check if webhook signature is valid
     */
    public function verifyWebhookSignature(string $payload, string $signature, string $secret): bool
    {
        $expectedSignature = hash_hmac('sha256', $payload, $secret);
        return hash_equals($expectedSignature, $signature);
    }
}
