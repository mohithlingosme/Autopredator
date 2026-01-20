<?php
declare(strict_types=1);

header('Content-Type: application/json');

require_once __DIR__ . '/../includes/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$email = trim($_POST['email'] ?? '');
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'Please enter a valid email.']);
    exit;
}

$saved = create_newsletter_subscriber($email);
if ($saved) {
    echo json_encode(['success' => true, 'message' => 'Thanks! You are on the list.']);
    exit;
}

http_response_code(500);
echo json_encode(['success' => false, 'message' => 'Could not save subscription. Please try again.']);
