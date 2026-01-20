<?php
declare(strict_types=1);

namespace App\Services;

use PDO;

class GDPRService
{
    private PDO $db;

    public function __construct(PDO $db)
    {
        $this->db = $db;
    }

    /**
     * Export all user data for GDPR compliance
     */
    public function exportUserData(int $userId): array
    {
        $data = [
            'user_profile' => $this->getUserProfile($userId),
            'subscriptions' => $this->getUserSubscriptions($userId),
            'payments' => $this->getUserPayments($userId),
            'usage_history' => $this->getUserUsageHistory($userId),
            'audit_logs' => $this->getUserAuditLogs($userId),
            'support_tickets' => $this->getUserSupportTickets($userId),
            'export_date' => date('c'),
            'gdpr_rights' => $this->getGDPRRights()
        ];

        return $data;
    }

    /**
     * Delete all user data for GDPR compliance (right to be forgotten)
     */
    public function deleteUserData(int $userId): bool
    {
        try {
            $this->db->beginTransaction();

            // Anonymize user data instead of deleting (for audit/compliance reasons)
            $this->anonymizeUserProfile($userId);
            $this->anonymizeAuditLogs($userId);
            $this->anonymizeSupportTickets($userId);

            // Mark user as deleted
            $stmt = $this->db->prepare("
                UPDATE users
                SET email = CONCAT('deleted_', id, '@anonymous.local'),
                    name = 'Deleted User',
                    deleted_at = NOW(),
                    gdpr_deleted = 1
                WHERE id = ?
            ");
            $stmt->execute([$userId]);

            $this->db->commit();
            return true;

        } catch (\Exception $e) {
            $this->db->rollBack();
            error_log('GDPR deletion error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Record user consent for data processing
     */
    public function recordConsent(int $userId, string $consentType, bool $consented, ?string $ipAddress = null): bool
    {
        $stmt = $this->db->prepare("
            INSERT INTO user_consents (user_id, consent_type, consented, ip_address, created_at)
            VALUES (?, ?, ?, ?, NOW())
        ");

        return $stmt->execute([$userId, $consentType, $consented ? 1 : 0, $ipAddress]);
    }

    /**
     * Get user's current consent status
     */
    public function getConsentStatus(int $userId): array
    {
        $stmt = $this->db->prepare("
            SELECT consent_type, consented, created_at
            FROM user_consents
            WHERE user_id = ?
            ORDER BY created_at DESC
        ");
        $stmt->execute([$userId]);

        $consents = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            if (!isset($consents[$row['consent_type']])) {
                $consents[$row['consent_type']] = $row;
            }
        }

        return $consents;
    }

    /**
     * Check if user has valid consent for a specific type
     */
    public function hasValidConsent(int $userId, string $consentType): bool
    {
        $stmt = $this->db->prepare("
            SELECT consented
            FROM user_consents
            WHERE user_id = ? AND consent_type = ?
            ORDER BY created_at DESC
            LIMIT 1
        ");
        $stmt->execute([$userId, $consentType]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result && $result['consented'];
    }

    private function getUserProfile(int $userId): ?array
    {
        $stmt = $this->db->prepare("
            SELECT id, name, email, role, org_id, created_at, updated_at
            FROM users
            WHERE id = ?
        ");
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    private function getUserSubscriptions(int $userId): array
    {
        $stmt = $this->db->prepare("
            SELECT s.*, p.name as plan_name
            FROM subscriptions s
            JOIN plans p ON s.plan_id = p.id
            WHERE s.org_id IN (
                SELECT org_id FROM users WHERE id = ?
            )
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function getUserPayments(int $userId): array
    {
        $stmt = $this->db->prepare("
            SELECT p.*
            FROM payments p
            JOIN subscriptions s ON p.subscription_id = s.id
            WHERE s.org_id IN (
                SELECT org_id FROM users WHERE id = ?
            )
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function getUserUsageHistory(int $userId): array
    {
        $stmt = $this->db->prepare("
            SELECT *
            FROM usage_counters
            WHERE org_id IN (
                SELECT org_id FROM users WHERE id = ?
            )
            ORDER BY period_start DESC
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function getUserAuditLogs(int $userId): array
    {
        $stmt = $this->db->prepare("
            SELECT *
            FROM audit_events
            WHERE user_id = ?
            ORDER BY created_at DESC
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function getUserSupportTickets(int $userId): array
    {
        $stmt = $this->db->prepare("
            SELECT t.*, COUNT(m.id) as message_count
            FROM support_tickets t
            LEFT JOIN support_messages m ON t.id = m.ticket_id
            WHERE t.user_id = ?
            GROUP BY t.id
            ORDER BY t.created_at DESC
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    private function anonymizeUserProfile(int $userId): void
    {
        // Keep minimal data for legal/compliance reasons
        $stmt = $this->db->prepare("
            UPDATE users
            SET name = 'Anonymous User',
                email = CONCAT('anonymous_', id, '@deleted.local'),
                gdpr_deleted = 1,
                deleted_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$userId]);
    }

    private function anonymizeAuditLogs(int $userId): void
    {
        $stmt = $this->db->prepare("
            UPDATE audit_events
            SET user_id = NULL,
                event_data = JSON_SET(event_data, '$.anonymized', true)
            WHERE user_id = ?
        ");
        $stmt->execute([$userId]);
    }

    private function anonymizeSupportTickets(int $userId): void
    {
        $stmt = $this->db->prepare("
            UPDATE support_tickets
            SET user_id = NULL,
                subject = 'Anonymized Ticket',
                description = 'This ticket has been anonymized due to GDPR deletion request'
            WHERE user_id = ?
        ");
        $stmt->execute([$userId]);

        $stmt = $this->db->prepare("
            UPDATE support_messages
            SET user_id = NULL,
                message = 'This message has been anonymized due to GDPR deletion request'
            WHERE user_id = ?
        ");
        $stmt->execute([$userId]);
    }

    private function getGDPRRights(): array
    {
        return [
            'right_to_access' => 'You have the right to access your personal data',
            'right_to_rectification' => 'You have the right to rectify inaccurate personal data',
            'right_to_erasure' => 'You have the right to erasure (right to be forgotten)',
            'right_to_restriction' => 'You have the right to restrict processing',
            'right_to_data_portability' => 'You have the right to data portability',
            'right_to_object' => 'You have the right to object to processing'
        ];
    }
}
