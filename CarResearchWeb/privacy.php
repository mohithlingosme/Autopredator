<?php
declare(strict_types=1);

require_once 'includes/bootstrap.php';

$pageTitle = 'Privacy Policy';
$pageDescription = 'Privacy policy for Autopredator car research platform';
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
            <h1>Privacy Policy</h1>

            <div class="legal-content">
                <p><strong>Last updated:</strong> <?php echo date('F j, Y'); ?></p>

                <h2>1. Information We Collect</h2>
                <p>We collect information you provide directly to us, such as when you create an account, make a purchase, or contact us for support.</p>

                <h2>2. How We Use Your Information</h2>
                <p>We use the information we collect to:</p>
                <ul>
                    <li>Provide, maintain, and improve our services</li>
                    <li>Process transactions and send related information</li>
                    <li>Send you technical notices, updates, security alerts, and support messages</li>
                    <li>Respond to your comments, questions, and requests</li>
                </ul>

                <h2>3. Information Sharing</h2>
                <p>We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.</p>

                <h2>4. Data Security</h2>
                <p>We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.</p>

                <h2>5. Data Retention</h2>
                <p>We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this privacy policy.</p>

                <h2>6. Your Rights</h2>
                <p>You have the right to access, update, or delete your personal information. You can also object to or restrict certain processing of your information.</p>

                <h2>7. Cookies</h2>
                <p>We use cookies and similar technologies to enhance your experience on our website. You can control cookie settings through your browser.</p>

                <h2>8. Changes to This Policy</h2>
                <p>We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.</p>

                <h2>9. Contact Us</h2>
                <p>If you have any questions about this privacy policy, please contact us at privacy@autopredator.com.</p>
            </div>
        </div>
    </main>

    <?php include 'includes/footer.php'; ?>
</body>
</html>
