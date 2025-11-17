<?php
// Database connection (PDO)
$host = 'localhost';
$db   = 'autopredator_unified';
$user = 'root';
$pass = '';
$charset = 'utf8mb4';
$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];
try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    echo "Database connection failed: " . $e->getMessage();
    exit;
}

// Sample SQL to create table and insert data
// Uncomment and run once to create table and insert sample data
/*
$pdo->exec("CREATE TABLE IF NOT EXISTS vehicle_services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    description TEXT
)");

$pdo->exec("INSERT INTO vehicle_services (service_name, description) VALUES
    ('Vehicle Servicing Reminder', 'Get timely reminders for your vehicle servicing.'),
    ('Service Center Locator', 'Find the nearest authorized service centers.'),
    ('Spare Part Checker', 'Check availability of spare parts for your vehicle.'),
    ('Mechanic Booking', 'Book a mechanic for on-site repairs.'),
    ('Car Service History', 'Track your car’s complete service history.'),
    ('Vehicle Diagnostics', 'Real-time vehicle diagnostics and alerts.'),
    ('Maintenance Cost Calculator', 'Estimate your vehicle maintenance costs.'),
    ('Roadside Assistance', 'On-demand roadside assistance for emergencies.')
");
*/

// Fetch data from database
$stmt = $pdo->query("SELECT * FROM vehicle_services");
$services = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Maintenance & Repairs</title>
    <style>
        :root {
            --bg-color: #f5f5f5;
            --text-color: #000;
            --header-bg: #1a1a2e;
            --button-bg: #e94560;
            --feature-bg: white;
            --footer-bg: #1a1a2e;
        }
        body.dark-mode {
            --bg-color: #1e1e1e;
            --text-color: #fff;
            --header-bg: #0d0d1a;
            --button-bg: #ff4c68;
            --feature-bg: #2a2a2a;
            --footer-bg: #0d0d1a;
        }
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--bg-color);
            color: var(--text-color);
            transition: background 0.3s, color 0.3s;
        }
        header {
            background: var(--header-bg);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .theme-toggle {
            background: none;
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
            transition: color 0.3s;
        }
        .container {
            width: 90%;
            max-width: 1200px;
            margin: 20px auto;
            background: var(--feature-bg);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .icon-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
            padding: 20px;
        }
        .icon-card {
            text-align: center;
            color: #fff;
            padding: 15px;
            background: var(--header-bg);
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s;
        }
        .icon-card:hover {
            transform: scale(1.05);
        }
        .icon-card img {
            width: 60px;
            height: 60px;
        }
        .icon-card h3 {
            margin-top: 10px;
            font-size: 16px;
            color: #fff !important;
        }
        .db-section { background: #fff; border-radius: 8px; margin: 2rem auto; max-width: 900px; box-shadow: 0 2px 8px rgba(0,0,0,0.07); padding: 2rem; }
        .db-section h2 { color: #e94560; }
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #e94560; color: #fff; }
        footer {
            background: var(--footer-bg);
            color: white;
            text-align: center;
            padding: 20px;
            margin-top: 40px;
        }
    </style>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const toggleButton = document.querySelector(".theme-toggle");
            toggleButton.addEventListener("click", function () {
                document.body.classList.toggle("dark-mode");
            });
        });
    </script>
</head>
<body>
    <header>
        <h1>Vehicle Maintenance & Repairs</h1>
        <button class="theme-toggle">🌙</button>
    </header>
    <div class="container db-section">
        <h2>Sample Vehicle Services from Database</h2>
        <table>
            <tr><th>Service Name</th><th>Description</th></tr>
            <?php foreach ($services as $service): ?>
                <tr>
                    <td><?= htmlspecialchars($service['service_name']) ?></td>
                    <td><?= htmlspecialchars($service['description']) ?></td>
                </tr>
            <?php endforeach; ?>
        </table>
    </div>
    <div class="container">
        <div class="icon-section">
            <div class="icon-card"><img src="service-reminder.png" alt="Service Reminders"><h3>Vehicle Servicing Reminders</h3></div>
            <div class="icon-card"><img src="locator.png" alt="Service Center Locator"><h3>Nearest Service Center Locator</h3></div>
            <div class="icon-card"><img src="spare-parts.png" alt="Spare Parts Checker"><h3>Spare Part Availability Checker</h3></div>
            <div class="icon-card"><img src="mechanic-booking.png" alt="Mechanic Booking"><h3>Mechanic Booking System</h3></div>
            <div class="icon-card"><img src="car-history.png" alt="Car Service History"><h3>Car Service History Tracker</h3></div>
            <div class="icon-card"><img src="diagnostics.png" alt="Vehicle Diagnostics"><h3>Real-time Vehicle Diagnostics</h3></div>
            <div class="icon-card"><img src="maintenance-cost.png" alt="Maintenance Cost"><h3>Maintenance Cost Calculator</h3></div>
            <div class="icon-card"><img src="roadside-assistance.png" alt="Roadside Assistance"><h3>On-demand Roadside Assistance</h3></div>
        </div>
    </div>
    <footer>
        <p>&copy; 2025 Vehicle Maintenance & Repair Services. All rights reserved.</p>
    </footer>
</body>
</html>
