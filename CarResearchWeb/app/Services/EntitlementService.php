<?php
declare(strict_types=1);

namespace App\Services;

use PDO;

/**
 * Entitlement Service - Manages feature access and usage limits
 */
class EntitlementService
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    /**
     * Check if organization can access a feature
     */
    public function canAccess(int $orgId, string $feature): bool
    {
        // Get current subscription
        $subscription = $this->getSubscription($orgId);
        if (!$subscription) {
            return false;
        }

        // Get plan features
        $stmt = $this->db->prepare("SELECT features FROM plans WHERE id = ?");
        $stmt->execute([$subscription['plan_id']]);
        $plan = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$plan) {
            return false;
        }

        $features = json_decode($plan['features'], true) ?: [];
        return in_array($feature, $features) || in_array('all', $features);
    }

    /**
     * Check and enforce usage limit
     */
    public function checkUsageLimit(int $orgId, string $metric, int $limit): bool
    {
        $currentUsage = $this->getCurrentUsage($orgId, $metric);
        return $currentUsage < $limit;
    }

    /**
     * Increment usage counter
     */
    public function incrementUsage(int $orgId, string $metric, int $increment = 1): void
    {
        $periodStart = date('Y-m-01'); // Monthly periods
        $periodEnd = date('Y-m-t');

        $stmt = $this->db->prepare("
            INSERT INTO usage_counters (org_id, metric, count, period_start, period_end, updated_at)
            VALUES (?, ?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE
                count = count + VALUES(count),
                updated_at = NOW()
        ");
        $stmt->execute([$orgId, $metric, $increment, $periodStart, $periodEnd]);
    }

    /**
     * Check if organization is in read-only mode
     */
    public function isReadOnly(int $orgId): bool
    {
        $subscription = $this->getSubscription($orgId);
        return $subscription && $subscription['status'] === 'read_only';
    }

    /**
     * Get current subscription for org
     */
    private function getSubscription(int $orgId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT * FROM subscriptions
            WHERE org_id = ? AND status IN ('active', 'trial', 'past_due', 'read_only')
            ORDER BY created_at DESC
            LIMIT 1
        ");
        $stmt->execute([$orgId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    /**
     * Get current usage for metric
     */
    private function getCurrentUsage(int $orgId, string $metric): int
    {
        $periodStart = date('Y-m-01');
        $stmt = $this->db->prepare("
            SELECT count FROM usage_counters
            WHERE org_id = ? AND metric = ? AND period_start = ?
        ");
        $stmt->execute([$orgId, $metric, $periodStart]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result ? (int)$result['count'] : 0;
    }

    /**
     * Get usage limits for current plan
     */
    public function getUsageLimits(int $orgId): array
    {
        $subscription = $this->getSubscription($orgId);
        if (!$subscription) {
            return [];
        }

        $stmt = $this->db->prepare("
            SELECT max_users, max_vehicles, max_exports
            FROM plans WHERE id = ?
        ");
        $stmt->execute([$subscription['plan_id']]);
        $plan = $stmt->fetch(PDO::FETCH_ASSOC);

        return $plan ?: [];
    }
}
