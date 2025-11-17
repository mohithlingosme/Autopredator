<?php include __DIR__ . '/../db_connect.php'; ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fleet Management</title>
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
        <h1>Fleet Management</h1>
        <button class="theme-toggle">🌙</button>
    </header>
    
    <div class="container">
        <div class="data-section">
            <h2>Fleet Data</h2>
            <?php
            $sql = "SELECT v.variant_name, m.name AS manufacturer, mo.name AS model FROM variants v JOIN models mo ON v.model_id = mo.id JOIN manufacturers m ON mo.manufacturer_id = m.id LIMIT 5";
            $result = $conn->query($sql);
            if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                    echo "<p>" . $row['manufacturer'] . " " . $row['model'] . " " . $row['variant_name'] . "</p>";
                }
            } else {
                echo "<p>No data available.</p>";
            }
            ?>
        </div>

        <div class="icon-section">
            <div class="icon-card">
                <img src="gps-icon.png" alt="GPS Icon">
                <h3>GPS Tracking</h3>
            </div>
            <div class="icon-card">
                <img src="fuel-icon.png" alt="Fuel Icon">
                <h3>Fuel Efficiency Monitoring</h3>
            </div>
            <div class="icon-card">
                <img src="compliance-icon.png" alt="Compliance Icon">
                <h3>Compliance Tracking</h3>
            </div>
            <div class="icon-card">
                <img src="driver-icon.png" alt="Driver Icon">
                <h3>Driver Management</h3>
            </div>
        </div>

        <div class="service-section">
            <h2>Fleet Management for Commercial, Agricultural, and Construction Vehicles</h2>
            <ul class="services-list">
                <li><a href="#">GPS Tracking: Real-time location tracking for logistics</a></li>
                <li><a href="#">Fuel Efficiency Monitoring: Optimize costs</a></li>
                <li><a href="#">Compliance Tracking: Manage legal compliance</a></li>
                <li><a href="#">Driver Management: Monitor productivity & safety</a></li>
            </ul>
        </div>
    </div>
    
    <footer>
        <p>&copy; 2025 Fleet Management Services. All rights reserved.</p>
    </footer>
</body>
</html>
