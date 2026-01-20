<?php
declare(strict_types=1);

require_once '../includes/bootstrap.php';
require_once '../app/Services/SupportService.php';

use App\Services\SupportService;

// Only authenticated users
if (!auth_is_logged_in()) {
    http_response_code(401);
    echo json_encode(['error' => 'Authentication required']);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$userId = $_SESSION['user_id'];
$orgId = $_SESSION['org_id'] ?? null;

$supportService = new SupportService(getDBConnection());

switch ($method) {
    case 'GET':
        // Get user's tickets
        $status = $_GET['status'] ?? null;
        $tickets = $supportService->getTickets($userId, $orgId, $status);

        // Add message counts
        foreach ($tickets as &$ticket) {
            $messages = $supportService->getTicketMessages($ticket['id']);
            $ticket['message_count'] = count($messages);
            $ticket['last_message'] = $messages ? end($messages)['created_at'] : null;
        }

        echo json_encode(['tickets' => $tickets]);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data || !isset($data['subject']) || !isset($data['description'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Subject and description required']);
            exit;
        }

        $ticketId = $supportService->createTicket(
            $userId,
            $orgId,
            $data['subject'],
            $data['description'],
            $data['category'] ?? 'general',
            $data['priority'] ?? 'medium'
        );

        echo json_encode(['ticket_id' => $ticketId, 'status' => 'created']);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
