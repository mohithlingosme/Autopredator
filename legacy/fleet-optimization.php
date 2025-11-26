<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fleet Optimization - Autopredator</title>
  <style>
    <style>
    :root {
      --primary-color: #007BFF;
      --accent-color: #39FF14;
      --background-color: #f8f9fa;
      --card-bg: #ffffff;
      --text-color: #333;
      --transition-speed: 0.3s;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: var(--background-color);
      color: var(--text-color);
      line-height: 1.6;
    }

    header {
      background-color: var(--primary-color);
      color: #fff;
      padding: 20px;
      text-align: center;
      animation: fadeInDown var(--transition-speed) ease-in-out;
    }

    nav ul {
      list-style: none;
      display: flex;
      justify-content: center;
      gap: 20px;
      margin-top: 10px;
    }

    nav a {
      color: #fff;
      text-decoration: none;
      font-weight: bold;
      transition: color var(--transition-speed);
    }

    nav a:hover {
      color: var(--accent-color);
    }

    #hero {
      background: linear-gradient(to right, #007BFF, #00bcd4);
      color: white;
      padding: 80px 20px;
      text-align: center;
      animation: fadeIn var(--transition-speed) ease-in;
    }

    #hero h2 {
      font-size: 2.5rem;
      margin-bottom: 10px;
    }

    #hero button {
      margin-top: 20px;
      padding: 10px 20px;
      font-size: 1rem;
      background-color: var(--accent-color);
      border: none;
      border-radius: 5px;
      cursor: pointer;
      transition: background-color var(--transition-speed);
    }

    #hero button:hover {
      background-color: #2ee82e;
    }

    section {
      padding: 60px 20px;
      text-align: center;
      animation: fadeInUp var(--transition-speed) ease-in;
    }

    .feature-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-top: 30px;
    }

    .feature-card {
      background-color: var(--card-bg);
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      transition: transform var(--transition-speed);
    }

    .feature-card:hover {
      transform: scale(1.05);
    }

    .chart-placeholder,
    .map-placeholder {
      height: 300px;
      background-color: #e0e0e0;
      margin-top: 20px;
      display: flex;
      justify-content: center;
      align-items: center;
      color: #555;
      border-radius: 10px;
    }

    footer {
      background-color: #343a40;
      color: white;
      text-align: center;
      padding: 20px 0;
      margin-top: 40px;
    }

    ul {
      text-align: left;
      max-width: 800px;
      margin: 20px auto;
    }

    li {
      padding: 5px 0;
    }

    @keyframes fadeInDown {
      from { opacity: 0; transform: translateY(-20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
  </style>
  </style>
</head>
<body>
  <header>
    <h1>Fleet Optimization Dashboard</h1>
    <nav>
      <ul>
        <li><a href="#features">Features</a></li>
        <li><a href="#analytics">Analytics</a></li>
        <li><a href="#tracking">Tracking</a></li>
        <li><a href="#compliance">Compliance</a></li>
      </ul>
    </nav>
  </header>

  <section id="hero">
    <h2>Streamline Your Fleet Operations</h2>
    <p>Real-time tracking, predictive maintenance, driver behavior analytics, and more!</p>
    <button onclick="scrollToFeatures()">Explore Features</button>
  </section>

  <section id="features">
    <h2>Key Features</h2>
    <div class="feature-grid">
      <div class="feature-card">Telematics Integration</div>
      <div class="feature-card">Real-Time Monitoring</div>
      <div class="feature-card">Fuel Optimization</div>
      <div class="feature-card">Fleet optimization tools </div>
      <div class="feature-card">Driver behavior monitoring </div>
      <div class="feature-card">compliance and safety tracking </div>
      <div class="feature-card">Cost tracking and predictive analytics </div>
      <div class="feature-card">Route and delivery optimization </div>
      <div class="feature-card">Driver scheduling and shift management </div>
      <div class="feature-card">Inspection and recall management </div>
      <div class="feature-card">Document storage</div>
      <div class="feature-card">Vehicle history and performance analysis </div>
      <div class="feature-card">Expense and tex deduction </div>
      <div class="feature-card">Marketplace </div>
      <div class="feature-card">Customization </div>
      <div class="feature-card">Predictive maintenance</div>
      <div class="feature-card">Drive Safety scores </div>
      <div class="feature-card">Cost optimization insights</div>
      <div class="feature-card">Smart alerts ad notification </div>
      <div class="feature-card">Envrionmental and emissions monitoring</div>
      <div class="feature-card">Geofencing capabilities </div>
      <div class="feature-card">Intergrated video telematics</div>
      <div class="feature-card">Mobile app access</div>
      <div class="feature-card">Scalability and integration </div>
      <div class="feature-card">Envrionmental impact monitoring</div>
      <div class="feature-card">Customizalble alert and reports </div>
      <div class="feature-card">Assets tracking </div>
      <div class="feature-card">Compliance management </div>
      <div class="feature-card">Driver Behavior Analysis</div>
      <div class="feature-card">Predictive Maintenance</div>
      <div class="feature-card">Compliance Alerts</div>
      <div class="feature-card">Advanced analytics and reporting </div>
    </div>
  </section>

  <section id="analytics">
    <h2>Fleet Analytics</h2>
    <p>View your operational costs, route efficiency, and fleet performance in real-time.</p>
    <!-- Placeholder for future chart integration -->
    <div class="chart-placeholder">[Analytics Chart Placeholder]</div>
  </section>

  <section id="tracking">
    <h2>Live Tracking</h2>
    <p>GPS-based tracking to keep your vehicles visible and secure.</p>
    <div class="map-placeholder">[Map Component Placeholder]</div>
  </section>

  <section id="compliance">
    <h2>Safety & Compliance</h2>
    <ul>
      <li>Automated Alerts for Inspections and Recalls</li>
      <li>Driver Behavior Monitoring</li>
      <li>Regulatory Compliance Tracking</li>
    </ul>
  </section>

  <footer>
    <p>&copy; 2025 Autopredator | Powered by Mohith</p>
  </footer>

  <script src="script.js"></script>
</body>
</html>
