<?php
// test_auth.php - Manual testing script for authentication and RBAC

session_start();
include 'config_users.php';
include 'includes/functions.php';

// Test 1: Check if functions are loaded
echo "=== Testing RBAC Functions ===\n";
echo "is_logged_in(): " . (is_logged_in() ? 'true' : 'false') . "\n";
echo "has_role('Admin'): " . (has_role('Admin') ? 'true' : 'false') . "\n";
echo "has_any_role(['Admin', 'Dealer']): " . (has_any_role(['Admin', 'Dealer']) ? 'true' : 'false') . "\n";

// Test 2: Check database connection
echo "\n=== Testing Database Connection ===\n";
if ($userConn->connect_error) {
    echo "Connection failed: " . $userConn->connect_error . "\n";
} else {
    echo "Connected successfully to autopredator_unified\n";

    // Test 3: Check if users table exists and has data
    $result = $userConn->query("SELECT COUNT(*) as count FROM users");
    if ($result) {
        $row = $result->fetch_assoc();
        echo "Users table exists with " . $row['count'] . " records\n";
    } else {
        echo "Users table query failed: " . $userConn->error . "\n";
    }

    // Test 4: Check sample users
    $result = $userConn->query("SELECT id, name, email, user_type FROM users LIMIT 5");
    if ($result) {
        echo "\nSample users:\n";
        while ($row = $result->fetch_assoc()) {
            echo "- ID: {$row['id']}, Name: {$row['name']}, Email: {$row['email']}, Type: {$row['user_type']}\n";
        }
    }
}

// Test 5: CSRF token generation
echo "\n=== Testing CSRF Token ===\n";
$token1 = generate_csrf_token();
$token2 = generate_csrf_token();
echo "Token 1: " . substr($token1, 0, 20) . "...\n";
echo "Token 2: " . substr($token2, 0, 20) . "...\n";
echo "Tokens match: " . ($token1 === $token2 ? 'true' : 'false') . "\n";

// Test 6: CSRF validation
echo "Validate token1: " . (validate_csrf_token($token1) ? 'true' : 'false') . "\n";
echo "Validate invalid token: " . (validate_csrf_token('invalid') ? 'true' : 'false') . "\n";

$userConn->close();
echo "\n=== Test Complete ===\n";
?>
