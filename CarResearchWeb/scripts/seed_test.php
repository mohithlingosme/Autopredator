<?php

echo "Seeding test database...\n";

// Connect to test DB
$host = getenv('DB_HOST') ?: 'localhost';
$db = getenv('DB_NAME') ?: 'autopredator_test';
$user = getenv('DB_USER') ?: 'testuser';
$pass = getenv('DB_PASS') ?: 'testpass';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Create tables if not exist
    $pdo->exec("CREATE TABLE IF NOT EXISTS test_cars (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        brand VARCHAR(100)
    )");

    // Insert test data
    $pdo->exec("INSERT INTO test_cars (name, brand) VALUES ('Test Car 1', 'Test Brand')");

    echo "✅ Test database seeded.\n";
} catch (Exception $e) {
    echo "❌ Error seeding test DB: " . $e->getMessage() . "\n";
    exit(1);
}
