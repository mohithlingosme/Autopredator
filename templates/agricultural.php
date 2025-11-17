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
$pdo->exec("CREATE TABLE IF NOT EXISTS agricultural_tools (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT
)");

$pdo->exec("INSERT INTO agricultural_tools (name, category, description) VALUES
    ('Plow', 'Soil Preparation', 'Turns over the upper layer of soil, bringing fresh nutrients to the surface while burying weeds and crop remains.'),
    ('Seed Drill', 'Planting Equipment', 'Ensures precise seed placement and optimal spacing for uniform crop emergence.'),
    ('Drip Irrigation', 'Irrigation Systems', 'Delivers water directly to plant roots, conserving water and reducing weed growth.'),
    ('Combine Harvester', 'Harvesting Tools', 'Integrates reaping, threshing, and winnowing into a single process for grain crops.'),
    ('Grain Silo', 'Storage Solutions', 'Provides secure storage for harvested grains, protecting them from pests and the elements.')
");
*/

// Fetch data from database
$stmt = $pdo->query("SELECT * FROM agricultural_tools");
$tools = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Agricultural Tools and Equipment</title>
  <style>
    body { margin: 0; font-family: 'Arial', sans-serif; background-color: #f4f4f4; color: #333; }
    header { background-color: #2E8B57; color: white; padding: 1.5rem 2rem; text-align: center; }
    nav ul { display: flex; justify-content: center; background-color: #3CB371; padding: 0.75rem; list-style: none; margin: 0; }
    nav ul li { margin: 0 1rem; }
    nav ul li a { color: white; text-decoration: none; }
    .hero { background: #228B22; color: white; text-align: center; padding: 3rem 2rem; }
    .section { padding: 2rem; max-width: 1100px; margin: auto; }
    .section h2 { color: #2E8B57; margin-bottom: 1rem; }
    .feature-box { background: white; border-left: 5px solid #2E8B57; margin: 1rem 0; padding: 1rem; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
    .db-section { background: #fff; border-radius: 8px; margin: 2rem auto; max-width: 900px; box-shadow: 0 2px 8px rgba(0,0,0,0.07); padding: 2rem; }
    .db-section h2 { color: #228B22; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #3CB371; color: #fff; }
    footer { background-color: #3CB371; color: white; text-align: center; padding: 1rem; margin-top: 3rem; }
  </style>
</head>
<body>
  <header>
    <h1>Agricultural Tools and Equipment</h1>
    <p>Empowering Modern Farming with Advanced Tools</p>
  </header>
  <nav>
    <ul>
      <li><a href="#overview">Overview</a></li>
      <li><a href="#soil-preparation">Soil Preparation</a></li>
      <li><a href="#planting">Planting Equipment</a></li>
      <li><a href="#irrigation">Irrigation Systems</a></li>
      <li><a href="#harvesting">Harvesting Tools</a></li>
      <li><a href="#storage">Storage Solutions</a></li>
    </ul>
  </nav>
  <section class="hero">
    <h2>Enhancing Agricultural Productivity</h2>
    <p>Discover a comprehensive range of tools and equipment designed to optimize every stage of farming.</p>
  </section>
  <section class="section" id="overview">
    <h2>Overview</h2>
    <p>Explore our extensive collection of agricultural tools and equipment that cater to various farming needs, ensuring efficiency and sustainability in modern agriculture.</p>
  </section>
  <section class="section db-section">
    <h2>Sample Tools from Database</h2>
    <table>
      <tr><th>Name</th><th>Category</th><th>Description</th></tr>
      <?php foreach ($tools as $tool): ?>
        <tr>
          <td><?= htmlspecialchars($tool['name']) ?></td>
          <td><?= htmlspecialchars($tool['category']) ?></td>
          <td><?= htmlspecialchars($tool['description']) ?></td>
        </tr>
      <?php endforeach; ?>
    </table>
  </section>
  <section class="section" id="soil-preparation">
    <h2>Soil Preparation</h2>
    <div class="feature-box">Plows: Essential for initial soil cultivation, turning over the upper layer to prepare for planting.</div>
    <div class="feature-box">Harrows: Used to break up and smooth out the surface of the soil after plowing.</div>
    <div class="feature-box">Cultivators: Designed to aerate the soil and remove weeds, promoting healthy crop growth.</div>
  </section>
  <section class="section" id="planting">
    <h2>Planting Equipment</h2>
    <div class="feature-box">Seed Drills: Ensure precise seed placement and optimal spacing for uniform crop emergence.</div>
    <div class="feature-box">Transplanters: Facilitate the efficient transfer of seedlings from nurseries to the field.</div>
  </section>
  <section class="section" id="irrigation">
    <h2>Irrigation Systems</h2>
    <div class="feature-box">Drip Irrigation: Delivers water directly to plant roots, conserving water and reducing weed growth.</div>
    <div class="feature-box">Sprinkler Systems: Mimic natural rainfall, providing even water distribution across fields.</div>
  </section>
  <section class="section" id="harvesting">
    <h2>Harvesting Tools</h2>
    <div class="feature-box">Combine Harvesters: Integrate reaping, threshing, and winnowing into a single process for grain crops.</div>
    <div class="feature-box">Sickles and Scythes: Traditional hand tools for cutting crops and grasses.</div>
  </section>
  <section class="section" id="storage">
    <h2>Storage Solutions</h2>
    <div class="feature-box">Grain Silos: Provide secure storage for harvested grains, protecting them from pests and the elements.</div>
    <div class="feature-box">Cold Storage Units: Essential for preserving perishable produce, extending shelf life and reducing waste.</div>
  </section>
  <footer>
    <p>&copy; 2025 AgriEquip Solutions. Innovating Agriculture for a Sustainable Future.</p>
  </footer>
</body>
</html>
