<?php
session_start();
include 'includes/functions.php';
require_login(); // Require user to be logged in

include 'config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Autopredator Unified Dashboard</title>
    <style>
        /* Root Variables */
        :root {
            --bg-color: #f5f5f5;
            --text-color: #000;
            --header-bg: #1a1a2e;
            --button-bg: #e94560;
            --feature-bg: white;
            --footer-bg: #1a1a2e;
        }

        /* Dark Mode */
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

        .container {
            width: 90%;
            max-width: 1200px;
            margin: 20px auto;
            background: var(--feature-bg);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        h1, h2 {
            color: var(--text-color);
        }

        .service-section h2 {
            background: var(--button-bg);
            color: white;
            padding: 10px;
            border-radius: 5px;
        }

        .services-list {
            list-style: none;
            padding: 0;
        }

        .services-list li {
            padding: 8px;
            border-bottom: 1px solid #ccc;
        }

        .services-list li a {
            text-decoration: none;
            color: var(--button-bg);
            font-weight: bold;
        }

        footer {
            background: var(--footer-bg);
            color: white;
            text-align: center;
            padding: 20px;
            margin-top: 40px;
        }
        .icon-section {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin-top: 20px;
        }

        .icon-card {
            text-align: center;
            padding: 15px;
            background: var(--feature-bg);
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 200px;
        }

        .icon-card img {
            width: 50px;
            height: 50px;
        }

        .stat-card {
            background: var(--feature-bg);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid var(--button-bg);
        }

        .stat-card h3 {
            margin: 0 0 10px 0;
            color: var(--button-bg);
            font-size: 2em;
        }

        .stat-card p {
            margin: 0;
            color: var(--text-color);
            opacity: 0.8;
        }

        .stat-card ul {
            text-align: left;
            margin-top: 10px;
        }

        .stat-card li {
            margin: 5px 0;
            font-size: 0.9em;
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
        <h1>Autopredator Services</h1>
        <div style="display: flex; align-items: center; gap: 15px;">
            <span>Welcome, <?php echo htmlspecialchars($_SESSION['user'] ?? 'User'); ?> (<?php echo htmlspecialchars($_SESSION['user_type'] ?? 'Customer'); ?>)</span>
            <a href="logout.php" style="color: white; text-decoration: none; padding: 5px 10px; background: #e94560; border-radius: 5px;">Logout</a>
            <button class="theme-toggle">🌙</button>
        </div>
    </header>
    
    <div class="container">
        <div class="data-section">
            <h2>Dashboard Overview</h2>

            <!-- Quick Stats -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px;">
                <?php
                // Total vehicles
                $vehicleCount = $conn->query("SELECT COUNT(*) as count FROM variants")->fetch_assoc()['count'];
                echo "<div class='stat-card'><h3>$vehicleCount</h3><p>Total Vehicles</p></div>";

                // Total blogs
                $blogCount = $conn->query("SELECT COUNT(*) as count FROM blogs WHERE status='published'")->fetch_assoc()['count'];
                echo "<div class='stat-card'><h3>$blogCount</h3><p>Published Blogs</p></div>";

                // Recent vehicles
                echo "<div class='stat-card'><h3>Recent Vehicles</h3><ul style='list-style: none; padding: 0;'>";
                $sql = "SELECT v.variant_name, m.name AS manufacturer FROM variants v JOIN models mo ON v.model_id = mo.id JOIN manufacturers m ON mo.manufacturer_id = m.id ORDER BY v.id DESC LIMIT 3";
                $result = $conn->query($sql);
                while($row = $result->fetch_assoc()) {
                    echo "<li>• " . $row['manufacturer'] . " " . $row['variant_name'] . "</li>";
                }
                echo "</ul></div>";
                ?>
            </div>

            <!-- Role-based content -->
            <?php if (has_role('Admin')): ?>
                <div class="admin-section" style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
                    <h3>Admin Panel</h3>
                    <p>As an administrator, you can:</p>
                    <ul>
                        <li><a href="admin.php">Manage Blog Posts</a></li>
                        <li><a href="api/">Access API Documentation</a></li>
                        <li>View system analytics and user management</li>
                    </ul>
                </div>
            <?php endif; ?>

            <?php if (has_role('Dealer')): ?>
                <div class="dealer-section" style="background: #e8f5e8; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
                    <h3>Dealer Dashboard</h3>
                    <p>As a dealer, you can:</p>
                    <ul>
                        <li><a href="api/vehicles">Manage Your Vehicle Listings</a></li>
                        <li>View sales analytics</li>
                        <li>Access customer inquiries</li>
                    </ul>
                </div>
            <?php endif; ?>
        </div>

        <div class="service-section">
            <h2>Vehicle Related Services</h2>
            <ul class="services-list">
                <li><a href="#">Pay Your Tax</a></li>
                <li><a href="#">Apply for Transfer of Ownership</a></li>
                <li><a href="#">Transfer of Ownership by Succession</a></li>
                <li><a href="#">Change of Address (BH Series)</a></li>
                <li><a href="#">Renewal of Registration</a></li>
                <li><a href="#">RC Surrender</a></li>
            </ul>
        </div>
        
        <div class="service-section">
            <h2>Permit Related Services</h2>
            <ul class="services-list">
                <li><a href="#">Goods Carrier Permit</a></li>
                <li><a href="#">National Permits</a></li>
                <li><a href="#">Passenger Vehicle Permits</a></li>
                <li><a href="#">Auto Rickshaw & Taxi Permit</a></li>
            </ul>
        </div>
        
        <div class="service-section">
            <h2>Driving License Services</h2>
            <ul class="services-list">
                <li><a href="#">Apply for Learner's License</a></li>
                <li><a href="#">Renew Driving License</a></li>
                <li><a href="#">Apply for International Driving License</a></li>
            </ul>
        </div>
        
        <div class="service-section">
            <h2>Tax & Payment Services</h2>
            <ul class="services-list">
                <li><a href="#">Check Payment Status</a></li>
                <li><a href="#">Print Payment Receipts</a></li>
                <li><a href="#">Check Pending Transactions</a></li>
            </ul>
        </div>
        
        <div class="service-section">
            <h2>More Services</h2>
            <ul class="services-list">
                <li><a href="#">E-Challan</a></li>
                <li><a href="#">Vehicle Scrapping</a></li>
                <li><a href="#">Know Your License Details</a></li>
                <li><a href="#">Downloadable Forms</a></li>
                <li><a href="#">Vahan & Sarathi Reports</a></li>
            </ul>
        </div>
    </div>
    
    <div class="container">
        <div class="icon-section">
            <div class="icon-card">
                <img src="C:\xampp\htdocs\Autopredator\images\insurance.png" alt="Insurance Icon">
                <h3>Insurance Tracking</h3>
            </div>
            <div class="icon-card">
                <img src="C:\xampp\htdocs\Autopredator\images\download.jpg" alt="Loan Icon">
                <h3>Loan & Lease Tracking</h3>
            </div>
            <div class="icon-card">
                <img src="C:\xampp\htdocs\Autopredator\images\maintainance.png" alt="Repair Icon">
                <h3>Repair & Maintenance</h3>
            </div>
        </div>
    <footer>
        <p>&copy; 2025 Autopredator Services. All rights reserved.</p>
    </footer>
</body>
</html>
// File moved to templates/unified dashboard.html
