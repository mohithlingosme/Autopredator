<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: contact.php');
    exit;
}

$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$company = trim($_POST['company'] ?? '');
$fleetSize = trim($_POST['fleet_size'] ?? '');
$message = trim($_POST['message'] ?? '');
$sourcePage = 'contact_page';

$errors = [];
if ($name === '') {
    $errors[] = 'Name is required.';
}
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'A valid email is required.';
}

if (empty($errors)) {
    try {
        $pdo = get_db_connection();
        $stmt = $pdo->prepare(
            'INSERT INTO leads (name, email, phone, company, fleet_size, message, source_page)
             VALUES (:name, :email, :phone, :company, :fleet_size, :message, :source_page)'
        );
        $stmt->execute([
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'company' => $company,
            'fleet_size' => $fleetSize,
            'message' => $message,
            'source_page' => $sourcePage,
        ]);

        send_lead_notification([
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'company' => $company,
            'fleet_size' => $fleetSize,
            'message' => $message,
            'source_page' => $sourcePage,
        ]);

        header('Location: thank-you.php');
        exit;
    } catch (PDOException $e) {
        error_log('Lead insert failed: ' . $e->getMessage());
        $errors[] = 'We could not save your request. Please try again.';
    }
}

renderPage([
    'title' => 'Contact Submitted | Autopredator',
    'description' => 'Contact form submission status.',
    'content' => __DIR__ . '/pages/contact-submit.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-contact-submission',
    'data' => ['errors' => $errors],
]);
