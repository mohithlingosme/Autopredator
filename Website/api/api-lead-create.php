<?php
declare(strict_types=1);

header('Content-Type: application/json');

require_once __DIR__ . '/../includes/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$source = trim($_POST['source_page'] ?? 'lead_capture');

$errors = [];
if ($name === '') {
    $errors[] = 'Name is required.';
}
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'A valid email is required.';
}

if (!empty($errors)) {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => implode(' ', $errors)]);
    exit;
}

$result = create_lead([
    'name' => $name,
    'email' => $email,
    'source_page' => $source,
]);

if ($result) {
    send_lead_notification(['name' => $name, 'email' => $email, 'source_page' => $source]);
    echo json_encode(['success' => true, 'message' => 'Thanks! We will reach out shortly.']);
    exit;
}

http_response_code(500);
echo json_encode(['success' => false, 'message' => 'Could not save your request. Please try again.']);
