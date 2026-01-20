<?php
declare(strict_types=1);

require_once 'bootstrap.php';
require_once '../app/Services/EntitlementService.php';

use App\Services\EntitlementService;

/**
 * Middleware to enforce entitlements on API endpoints
 */
class EntitlementMiddleware
{
    private EntitlementService $entitlementService;

    public function __construct()
    {
        $this->entitlementService = new EntitlementService(getDBConnection());
    }

    /**
     * Check if user/org can access premium feature
     */
    public function enforceFeatureAccess(string $feature): void
    {
        $orgId = $this->getCurrentOrgId();

        if (!$orgId) {
            $this->denyAccess('No organization context');
        }

        if (!$this->entitlementService->canAccess($orgId, $feature)) {
            $this->denyAccess('Feature not available in current plan');
        }
    }

    /**
     * Check and enforce usage limits
     */
    public function enforceUsageLimit(string $metric, int $limit): void
    {
        $orgId = $this->getCurrentOrgId();

        if (!$orgId) {
            $this->denyAccess('No organization context');
        }

        if (!$this->entitlementService->checkUsageLimit($orgId, $metric, $limit)) {
            $this->denyAccess('Usage limit exceeded');
        }
    }

    /**
     * Check if org is in read-only mode
     */
    public function checkReadOnly(): void
    {
        $orgId = $this->getCurrentOrgId();

        if ($orgId && $this->entitlementService->isReadOnly($orgId)) {
            $this->denyAccess('Account is in read-only mode due to billing issues');
        }
    }

    /**
     * Get current organization ID from session/user context
     */
    private function getCurrentOrgId(): ?int
    {
        // Check if user is logged in and has org_id
        if (!isset($_SESSION['user_id'])) {
            return null;
        }

        $stmt = getDBConnection()->prepare("SELECT org_id FROM users WHERE id = ?");
        $stmt->execute([$_SESSION['user_id']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        return $user ? $user['org_id'] : null;
    }

    /**
     * Deny access with JSON response
     */
    private function denyAccess(string $message): void
    {
        http_response_code(403);
        header('Content-Type: application/json');
        echo json_encode([
            'error' => 'Access denied',
            'message' => $message,
            'upgrade_required' => true
        ]);
        exit;
    }
}

// Global middleware instance
$entitlementMiddleware = new EntitlementMiddleware();
