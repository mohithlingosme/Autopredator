<?php
declare(strict_types=1);

namespace App\Services;

use PDO;

class DunningService
{
    private PDO $db;
    private array $dunningConfig;

    public function __construct(PDO $db)
    {
        $this->db = $db;
        $this->dunningConfig = [
            'grace_period_days' => 3, // Days after payment failure before first reminder
            'reminder_intervals' => [1, 3, 7, 14], // Days between reminders
            'max_reminders' => 4,
            'final_notice_days' => 30, // Days before account suspension
            'suspension_days' => 60, // Days before permanent suspension
        ];
    }

    /**
     * Process failed payments and send appropriate dunning emails
     */
    public function processFailedPayments(): array
    {
        $results = [
            'processed' => 0,
            'emails_sent' => 0,
            'accounts_suspended' => 0,
            'errors' => []
        ];

        try {
            // Get failed payments that need dunning action
            $failedPayments = $this->getFailedPaymentsNeedingAction();

            foreach ($failedPayments as $payment) {
                try {
                    $this->processPaymentFailure($payment);
                    $results['processed']++;
                } catch (\Exception $e) {
                    $results['errors'][] = "Payment {$payment['id']}: " . $e->getMessage();
                }
            }

            // Check for accounts that need suspension
            $accountsToSuspend = $this->getAccountsNeedingSuspension();
            foreach ($accountsToSuspend as $account) {
                try {
                    $this->suspendAccount($account);
                    $results['accounts_suspended']++;
                } catch (\Exception $e) {
                    $results['errors'][] = "Account suspension {$account['id']}: " . $e->getMessage();
                }
            }

        } catch (\Exception $e) {
            $results['errors'][] = 'General error: ' . $e->getMessage();
        }

        return $results;
    }

    /**
     * Send dunning email for a specific failed payment
     */
    public function sendDunningEmail(int $paymentId): bool
    {
        $payment = $this->getPaymentWithSubscription($paymentId);
        if (!$payment) {
            throw new \Exception("Payment not found: {$paymentId}");
        }

        $subscription = $this->getSubscriptionWithOrg($payment['subscription_id']);
        if (!$subscription) {
            throw new \Exception("Subscription not found: {$payment['subscription_id']}");
        }

        $dunningLevel = $this->calculateDunningLevel($payment);
        $emailTemplate = $this->getDunningEmailTemplate($dunningLevel);

        // In a real implementation, you would integrate with an email service
        // For now, we'll log the email that would be sent
        $this->logDunningEmail($paymentId, $dunningLevel, $emailTemplate);

        // Update payment dunning status
        $this->updatePaymentDunningStatus($paymentId, $dunningLevel);

        return true;
    }

    /**
     * Get failed payments that need dunning action
     */
    private function getFailedPaymentsNeedingAction(): array
    {
        $gracePeriod = $this->dunningConfig['grace_period_days'];

        $stmt = $this->db->prepare("
            SELECT p.*, s.org_id
            FROM payments p
            JOIN subscriptions s ON p.subscription_id = s.id
            WHERE p.status = 'failed'
            AND p.created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
            AND NOT EXISTS (
                SELECT 1 FROM dunning_emails de
                WHERE de.payment_id = p.id
                AND de.sent_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
            )
        ");

        $stmt->execute([$gracePeriod]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Process a single payment failure
     */
    private function processPaymentFailure(array $payment): void
    {
        $dunningLevel = $this->calculateDunningLevel($payment);

        if ($dunningLevel <= $this->dunningConfig['max_reminders']) {
            $this->sendDunningEmail($payment['id']);
        } else {
            // Max reminders reached, escalate to account suspension
            $this->markForSuspension($payment['subscription_id']);
        }
    }

    /**
     * Calculate the current dunning level for a payment
     */
    private function calculateDunningLevel(array $payment): int
    {
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as email_count
            FROM dunning_emails
            WHERE payment_id = ?
        ");

        $stmt->execute([$payment['id']]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        return ($result['email_count'] ?? 0) + 1;
    }

    /**
     * Get dunning email template based on level
     */
    private function getDunningEmailTemplate(int $level): array
    {
        $templates = [
            1 => [
                'subject' => 'Payment Failed - Please Update Your Payment Method',
                'body' => 'Dear customer, your recent payment failed. Please update your payment method to avoid service interruption.',
                'urgency' => 'low'
            ],
            2 => [
                'subject' => 'Second Notice: Payment Failed',
                'body' => 'This is your second notice about a failed payment. Your service may be interrupted if payment is not received.',
                'urgency' => 'medium'
            ],
            3 => [
                'subject' => 'Final Notice: Account Suspension Imminent',
                'body' => 'Your account will be suspended in 7 days if payment is not received. Contact support immediately.',
                'urgency' => 'high'
            ],
            4 => [
                'subject' => 'URGENT: Account Suspension Notice',
                'body' => 'Your account has been suspended due to non-payment. Contact support to reactivate.',
                'urgency' => 'urgent'
            ]
        ];

        return $templates[$level] ?? $templates[4];
    }

    /**
     * Log dunning email (in real implementation, send actual email)
     */
    private function logDunningEmail(int $paymentId, int $level, array $template): void
    {
        $stmt = $this->db->prepare("
            INSERT INTO dunning_emails (payment_id, dunning_level, subject, body, sent_at)
            VALUES (?, ?, ?, ?, NOW())
        ");

        $stmt->execute([
            $paymentId,
            $level,
            $template['subject'],
            $template['body']
        ]);

        // Log to audit
        $this->logAuditEvent('dunning_email_sent', [
            'payment_id' => $paymentId,
            'level' => $level,
            'subject' => $template['subject']
        ]);
    }

    /**
     * Update payment dunning status
     */
    private function updatePaymentDunningStatus(int $paymentId, int $level): void
    {
        $stmt = $this->db->prepare("
            UPDATE payments
            SET dunning_level = ?, last_dunning_attempt = NOW()
            WHERE id = ?
        ");

        $stmt->execute([$level, $paymentId]);
    }

    /**
     * Mark subscription for suspension
     */
    private function markForSuspension(int $subscriptionId): void
    {
        $stmt = $this->db->prepare("
            UPDATE subscriptions
            SET status = 'past_due',
                suspension_date = DATE_ADD(NOW(), INTERVAL ? DAY)
            WHERE id = ?
        ");

        $stmt->execute([$this->dunningConfig['final_notice_days'], $subscriptionId]);
    }

    /**
     * Get accounts that need to be suspended
     */
    private function getAccountsNeedingSuspension(): array
    {
        $stmt = $this->db->prepare("
            SELECT s.*, o.name as org_name, o.email as org_email
            FROM subscriptions s
            JOIN organizations o ON s.org_id = o.id
            WHERE s.status = 'past_due'
            AND s.suspension_date <= NOW()
            AND s.suspended_at IS NULL
        ");

        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Suspend an account
     */
    private function suspendAccount(array $account): void
    {
        $this->db->beginTransaction();

        try {
            // Update subscription status
            $stmt = $this->db->prepare("
                UPDATE subscriptions
                SET status = 'read_only', suspended_at = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$account['id']]);

            // Log suspension
            $this->logAuditEvent('account_suspended', [
                'subscription_id' => $account['id'],
                'org_id' => $account['org_id'],
                'reason' => 'payment_failure'
            ]);

            $this->db->commit();

        } catch (\Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }

    /**
     * Get payment with subscription details
     */
    private function getPaymentWithSubscription(int $paymentId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT p.*, s.org_id
            FROM payments p
            JOIN subscriptions s ON p.subscription_id = s.id
            WHERE p.id = ?
        ");

        $stmt->execute([$paymentId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get subscription with organization details
     */
    private function getSubscriptionWithOrg(int $subscriptionId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT s.*, o.name as org_name, o.email as org_email
            FROM subscriptions s
            JOIN organizations o ON s.org_id = o.id
            WHERE s.id = ?
        ");

        $stmt->execute([$subscriptionId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Log audit event
     */
    private function logAuditEvent(string $eventType, array $eventData): void
    {
        $stmt = $this->db->prepare("
            INSERT INTO audit_events (event_type, event_data, created_at)
            VALUES (?, ?, NOW())
        ");

        $stmt->execute([$eventType, json_encode($eventData)]);
    }

    /**
     * Get dunning statistics
     */
    public function getDunningStats(): array
    {
        $stats = [];

        // Failed payments by dunning level
        $stmt = $this->db->prepare("
            SELECT dunning_level, COUNT(*) as count
            FROM payments
            WHERE status = 'failed' AND dunning_level > 0
            GROUP BY dunning_level
        ");
        $stmt->execute();
        $stats['failed_payments_by_level'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Suspended accounts
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as count
            FROM subscriptions
            WHERE status = 'read_only' AND suspended_at IS NOT NULL
        ");
        $stmt->execute();
        $stats['suspended_accounts'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

        // Emails sent today
        $stmt = $this->db->prepare("
            SELECT COUNT(*) as count
            FROM dunning_emails
            WHERE DATE(sent_at) = CURDATE()
        ");
        $stmt->execute();
        $stats['emails_sent_today'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

        return $stats;
    }
}
