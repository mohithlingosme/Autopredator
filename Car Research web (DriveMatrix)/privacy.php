<?php
declare(strict_types=1);

$page_title = 'Privacy Policy';
$page_description = 'Autopredator privacy policy.';

require_once __DIR__ . '/includes/header.php';
?>

<section class="hero hero-small">
    <div class="container">
        <h1>Privacy Policy</h1>
        <p>How we handle your data on Autopredator.</p>
    </div>
</section>

<section class="section container">
    <div class="card">
        <h2>Overview</h2>
        <p>Autopredator stores only necessary session data (e.g., favourites and compare selections) and any form inputs you submit (login, registration, contact).</p>
        <h3>Data Collected</h3>
        <ul>
            <li>Session data for authentication and favourites.</li>
            <li>Form inputs (contact, login/register) provided by you.</li>
            <li>No third-party trackers are included in this demo.</li>
        </ul>
        <h3>Security</h3>
        <p>Passwords are hashed via PHP password_hash; database access uses prepared statements in the repository layer.</p>
    </div>
</section>

<?php
require_once __DIR__ . '/includes/footer.php';
