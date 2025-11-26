<?php
// Database connection (PDO)
$host = 'localhost';
$db   = 'autopredator';
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
$pdo->exec("CREATE TABLE IF NOT EXISTS insurance_tools (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tool_name VARCHAR(100) NOT NULL,
    description TEXT
)");
$pdo->exec("INSERT INTO insurance_tools (tool_name, description) VALUES
    ('Insurance Comparison', 'Compare policies to find the best plan.'),
    ('Premium Calculator', 'Estimate insurance premium quickly.'),
    ('Claim Management', 'Track and manage insurance claims.'),
    ('Two-Wheeler Support', 'Insurance for motorcycles and scooters.'),
    ('Commercial Vehicle', 'Insurance for logistics and transport vehicles.'),
    ('Agricultural Vehicle', 'Coverage for tractors and farm vehicles.'),
    ('EV Insurance', 'Insurance for electric vehicles.'),
    ('Policy Reminders', 'Get notified before your insurance expires.'),
    ('Claim Filing Support', 'Help with claim submissions.'),
    ('Cashless Garages', 'Find authorized repair centers.')
");
*/
$stmt = $pdo->query("SELECT * FROM insurance_tools");
$tools = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>AutoPredator - Insurance Tools</title>
  <style>
    :root {
      --bg: #f5f5f5;
      --text: #111;
      --primary: #e94560;
      --card-bg: #fff;
      --card-hover: #2d2d5b;
      --header-bg: #1a1a2e;
      --footer-bg: #1a1a2e;
    }
    body.dark-mode {
      --bg: #1e1e1e;
      --text: #fff;
      --card-bg: #2a2a2a;
      --card-hover: #38385a;
      --primary: #ff4c68;
    }
    body {
      margin: 0;
      font-family: Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      transition: all 0.3s ease;
    }
    header {
      background: var(--header-bg);
      color: white;
      padding: 20px 30px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .theme-toggle {
      font-size: 24px;
      background: none;
      border: none;
      color: white;
      cursor: pointer;
    }
    .db-section { background: #fff; border-radius: 8px; margin: 2rem auto; max-width: 900px; box-shadow: 0 2px 8px rgba(0,0,0,0.07); padding: 2rem; }
    .db-section h2 { color: #e94560; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #e94560; color: #fff; }
    .hero { padding: 40px; text-align: center; background: var(--card-bg); margin: 20px auto; max-width: 90%; border-radius: 12px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    .hero h1 { font-size: 36px; }
    .hero p { font-size: 18px; margin-bottom: 20px; }
    .hero .cta { background: var(--primary); color: white; border: none; padding: 12px 24px; font-size: 16px; border-radius: 5px; cursor: pointer; }
    .tools-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; padding: 40px 30px; }
    .card { background: var(--card-bg); padding: 20px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); transition: 0.3s ease; }
    .card:hover { background: var(--card-hover); transform: scale(1.05); color: white; }
    .card h3 { margin-top: 10px; font-size: 20px; }
    .card p { font-size: 14px; }
    .card .btn { margin-top: 10px; display: inline-block; background: var(--primary); color: white; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-size: 14px; }
    footer { background: var(--footer-bg); color: white; text-align: center; padding: 20px; margin-top: 30px; }
  </style>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const toggleBtn = document.querySelector(".theme-toggle");
      toggleBtn.addEventListener("click", () => {
        document.body.classList.toggle("dark-mode");
      });
    });
  </script>
</head>
<body>
  <header>
    <h2>AutoPredator Insurance Tools</h2>
    <button class="theme-toggle">🌙</button>
  </header>
  <div class="db-section">
    <h2>Sample Insurance Tools from Database</h2>
    <table>
      <tr><th>Tool Name</th><th>Description</th></tr>
      <?php foreach ($tools as $tool): ?>
        <tr>
          <td><?= htmlspecialchars($tool['tool_name']) ?></td>
          <td><?= htmlspecialchars($tool['description']) ?></td>
        </tr>
      <?php endforeach; ?>
    </table>
  </div>
  <section class="hero">
    <h1>Secure Your Fleet & Finances</h1>
    <p>Explore insurance tools tailored for vehicle owners, drivers, and businesses.</p>
    <a class="cta" href="insurancefinance.php">Go to Dashboard</a>
  </section>
  <section class="tools-grid">
    <div class="card">
      <h3>Insurance Comparison</h3>
      <p>Compare policies to find the best plan for your needs.</p>
      <a class="btn" href="#">Explore</a>
    </div>
    <div class="card">
      <h3>Premium Calculator</h3>
      <p>Estimate insurance premium quickly and accurately.</p>
      <a class="btn" href="#">Calculate</a>
    </div>
    <div class="card">
      <h3>Claim Management</h3>
      <p>Track and manage insurance claims efficiently.</p>
      <a class="btn" href="#">Manage</a>
    </div>
    <div class="card">
      <h3>Two-Wheeler Support</h3>
      <p>Insurance assistance for motorcycles and scooters.</p>
      <a class="btn" href="#">Assist</a>
    </div>
    <div class="card">
      <h3>Commercial Vehicle</h3>
      <p>Get insurance plans for logistics and transport vehicles.</p>
      <a class="btn" href="#">Quote</a>
    </div>
    <div class="card">
      <h3>Agricultural Vehicle</h3>
      <p>Special coverage for tractors and farm vehicles.</p>
      <a class="btn" href="#">Check Plans</a>
    </div>
    <div class="card">
      <h3>EV Insurance</h3>
      <p>Tailored insurance solutions for electric vehicles.</p>
      <a class="btn" href="#">Insure</a>
    </div>
    <div class="card">
      <h3>Policy Reminders</h3>
      <p>Get notified before your insurance expires.</p>
      <a class="btn" href="#">Set Reminder</a>
    </div>
    <div class="card">
      <h3>Claim Filing Support</h3>
      <p>Help with quick and correct claim submissions.</p>
      <a class="btn" href="#">File Claim</a>
    </div>
    <div class="card">
      <h3>Cashless Garages</h3>
      <p>Find authorized repair centers near you.</p>
      <a class="btn" href="#">Search</a>
    </div>
  </section>
  <footer>
    <p>&copy; 2025 AutoPredator Insurance Tools. All rights reserved.</p>
  </footer>
</body>
</html>
