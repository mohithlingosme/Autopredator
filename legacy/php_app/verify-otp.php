<?php
session_start();
require_once 'config_users.php';

$email = $_SESSION['email_pending'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $enteredOtp = $_POST['otp'];

    $stmt = $userConn->prepare("SELECT id FROM users WHERE email = ? AND otp_code = ?");
    $stmt->bind_param("ss", $email, $enteredOtp);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        // ✅ Verified successfully
        $update = $userConn->prepare("UPDATE users SET is_verified = 1, otp_code = NULL WHERE email = ?");
        $update->bind_param("s", $email);
        $update->execute();

        $_SESSION['user'] = $email;
        unset($_SESSION['email_pending']);
        header("Location: index.php");
        exit;
    } else {
        $error = "Invalid or expired OTP.";
    }
}
?>

<!-- Basic OTP form -->
<form method="POST">
    <label>Enter the 6-digit OTP sent to your email:</label>
    <input type="text" name="otp" required maxlength="6">
    <button type="submit">Verify</button>
    <?php if (isset($error)) echo "<p style='color:red;'>$error</p>"; ?>
</form>
