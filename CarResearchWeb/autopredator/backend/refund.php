<?php
declare(strict_types=1);

require_once 'includes/bootstrap.php';

$pageTitle = 'Refund Policy';
$pageDescription = 'Refund policy for Autopredator car research platform';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($pageTitle); ?> - Autopredator</title>
    <meta name="description" content="<?php echo htmlspecialchars($pageDescription); ?>">
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
    <?php include 'includes/header.php'; ?>

    <main class="container">
        <div class="content-wrapper">
            <h1>Refund Policy</h1>

            <div class="legal-content">
                <p><strong>Last updated:</strong> <?php echo date('F j, Y'); ?></p>

                <h2>1. Refund Eligibility</h2>
                <p>We offer refunds for our services under the following conditions:</p>
                <ul>
                    <li>Technical issues preventing service usage for more than 24 hours</li>
                    <li>Service not matching the advertised features</li>
                    <li>Duplicate charges or billing errors</li>
                </ul>

                <h2>2. Refund Process</h2>
                <p>To request a refund:</p>
                <ol>
                    <li>Contact our support team at support@autopredator.com</li>
                    <li>Provide your order number and reason for the refund request</li>
                    <li>Include any relevant screenshots or documentation</li>
                    <li>Allow 3-5 business days for review</li>
                </ol>

                <h2>3. Refund Timeline</h2>
                <p>Approved refunds will be processed within:</p>
                <ul>
                    <li>5-7 business days for credit card refunds</li>
                    <li>10-14 business days for bank transfer refunds</li>
                    <li>Instant refunds for wallet/balance credits</li>
                </ul>

                <h2>4. Non-Refundable Items</h2>
                <p>The following are not eligible for refunds:</p>
                <ul>
                    <li>Services used beyond the trial period</li>
                    <li>Change of mind or buyer's remorse</li>
                    <li>Third-party integrations or custom development</li>
                    <li>Subscription fees after the first billing cycle</li>
                </ul>

                <h2>5. Partial Refunds</h2>
                <p>In some cases, we may offer partial refunds based on usage or the nature of the issue. The refund amount will be determined at our discretion.</p>

                <h2>6. Subscription Cancellations</h2>
                <p>Subscription cancellations take effect at the end of the current billing period. No refunds are provided for the remaining days in the current period.</p>

                <h2>7. Contact Information</h2>
                <p>For refund requests or questions about this policy, please contact us at:</p>
                <ul>
                    <li>Email: refunds@autopredator.com</li>
                    <li>Support Portal: https://support.autopredator.com</li>
                    <li>Phone: +1 (555) 123-4567 (Mon-Fri, 9AM-5PM EST)</li>
                </ul>

                <h2>8. Policy Changes</h2>
                <p>We reserve the right to modify this refund policy at any time. Changes will be effective immediately upon posting on this page.</p>
            </div>
        </div>
    </main>

    <?php include 'includes/footer.php'; ?>
</body>
</html>
