<?php
declare(strict_types=1);

require_once '../includes/bootstrap.php';
require_once '../app/Services/GDPRService.php';

use App\Services\GDPRService;

// Only authenticated users
if (!auth_is_logged_in()) {
    http_response_code(401);
    echo json_encode(['error' => 'Authentication required']);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$userId = $_SESSION['user_id'];
$gdprService = new GDPRService(getDBConnection());

switch ($method) {
    case 'GET':
        // Export user data
        $data = $gdprService->exportUserData($userId);

        // Set headers for file download
        header('Content-Type: application/json');
        header('Content-Disposition: attachment; filename="gdpr-export-' . date('Y-m-d') . '.json"');
        header('Cache-Control: no-cache, no-store, must-revalidate');

        echo json_encode($data, JSON_PRETTY_PRINT);
        break;

    case 'DELETE':
        // Delete user data (right to be forgotten)
        $result = $gdprService->deleteUserData($userId);

        if ($result) {
            // Log the user out after deletion
            auth_logout();
            echo json_encode([
                'success' => true,
                'message' => 'Your data has been deleted successfully. You have been logged out.'
            ]);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to delete user data']);
        }
        break;

    case 'POST':
        // Handle consent updates
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data || !isset($data['consent_type']) || !isset($data['consented'])) {
            http_response_code(400);
            echo json_encode(['error' => 'consent_type and consented fields required']);
            exit;
        }

        $result = $gdprService->recordConsent(
            $userId,
            $data['consent_type'],
            (bool)$data['consented'],
            $_SERVER['REMOTE_ADDR'] ?? null
        );

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Consent recorded']);
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to record consent']);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
