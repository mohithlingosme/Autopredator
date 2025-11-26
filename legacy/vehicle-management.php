<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Maintenance & Repairs</title>
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
