<?php
declare(strict_types=1);

require_once '../includes/bootstrap.php';
require_once '../includes/entitlement_middleware.php';

// Enforce read-only check
global $entitlementMiddleware;
$entitlementMiddleware->checkReadOnly();

// Enforce usage limit for premium feature
$entitlementMiddleware->enforceFeatureAccess('detailed_specs');

// Get variant details
$variantId = (int)($_GET['id'] ?? 0);

if (!$variantId) {
    http_response_code(400);
    echo json_encode(['error' => 'Variant ID required']);
    exit;
}

try {
    $stmt = getDBConnection()->prepare("
        SELECT v.*, m.name as model_name, mf.nameplate as family_name, mf.body_type,
               vs.*, c.name as city_name
        FROM variants v
        JOIN models m ON v.model_id = m.id
        JOIN model_families mf ON m.family_id = mf.id
        LEFT JOIN vehicle_specs vs ON v.id = vs.variant_id
        LEFT JOIN cities c ON c.id = ?
        WHERE v.id = ? AND v.is_active = 1
    ");
    $stmt->execute([$_GET['city'] ?? null, $variantId]);
    $variant = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$variant) {
        http_response_code(404);
        echo json_encode(['error' => 'Variant not found']);
        exit;
    }

    // Increment usage counter
    $entitlementService = new \App\Services\EntitlementService(getDBConnection());
    $orgId = $entitlementMiddleware->getCurrentOrgId();
    if ($orgId) {
        $entitlementService->incrementUsage($orgId, 'detailed_specs_view');
    }

    echo json_encode($variant);

} catch (Exception $e) {
    error_log('Details API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
