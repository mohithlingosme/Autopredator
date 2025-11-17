<?php include 'db_connect.php'; ?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Compliance & Regulations | Fleet Management</title>
  <style>
    body {
      margin: 0;
      font-family: 'Arial', sans-serif;
      background-color: #f4f4f4;
      color: #333;
    }
    header {
      background-color: #0056b3;
      color: white;
      padding: 1.5rem 2rem;
      text-align: center;
    }
    nav ul {
      display: flex;
      justify-content: center;
      background-color: #003d82;
      padding: 0.75rem;
      list-style: none;
      margin: 0;
    }
    nav ul li {
      margin: 0 1rem;
    }
    nav ul li a {
      color: white;
      text-decoration: none;
    }
    .hero {
      background: #007bff;
      color: white;
      text-align: center;
      padding: 3rem 2rem;
    }
    .section {
      padding: 2rem;
      max-width: 1100px;
      margin: auto;
    }
    .section h2 {
      color: #0056b3;
      margin-bottom: 1rem;
    }
    .feature-box {
      background: white;
      border-left: 5px solid #0056b3;
      margin: 1rem 0;
      padding: 1rem;
      box-shadow: 0 2px 6px rgba(0,0,0,0.05);
    }
    footer {
      background-color: #003d82;
      color: white;
      text-align: center;
      padding: 1rem;
      margin-top: 3rem;
    }
  </style>
</head>
<body>
  <header>
    <h1>Compliance & Regulations</h1>
    <p>Ensure Your Fleet Meets All Legal Standards</p>
  </header>

  <nav>
    <ul>
      <li><a href="#overview">Overview</a></li>
      <li><a href="#vehicle-compliance">Vehicle Compliance</a></li>
      <li><a href="#driver-compliance">Driver Compliance</a></li>
      <li><a href="#reporting">Reporting & Auditing</a></li>
    </ul>
  </nav>

  <section class="hero">
    <h2>Stay Compliant, Stay Ahead</h2>
    <p>Manage all your fleet's compliance needs in one place, from vehicle inspections to driver certifications and regulatory reporting.</p>
  </section>

  <section class="section" id="data">
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
  </section>

  <section class="section" id="overview">
    <h2>Overview</h2>
    <p>The Compliance & Regulations module is designed to help fleet managers ensure that all vehicles and drivers meet local and national legal requirements. By centralizing compliance tasks, you can avoid penalties, reduce risks, and maintain operational efficiency.</p>
  </section>

  <section class="section" id="vehicle-compliance">
    <h2>Vehicle Compliance</h2>
    <div class="feature-box">Vehicle Inspection Scheduling & Records</div>
    <div class="feature-box">Registration & Insurance Tracking</div>
    <div class="feature-box">Emission Standards Compliance Monitoring</div>
    <div class="feature-box">Maintenance Logs & Alerts</div>
    <div class="feature-box">Permit & Licensing Management</div>
  </section>

  <section class="section" id="driver-compliance">
    <h2>Driver Compliance</h2>
    <div class="feature-box">Driver's License Verification & Expiry Alerts</div>
    <div class="feature-box">Training & Certification Records</div>
    <div class="feature-box">Hours of Service (HOS) Monitoring</div>
    <div class="feature-box">Health & Safety Compliance Tracking</div>
    <div class="feature-box">Incident & Violation Reporting</div>
  </section>

  <section class="section" id="reporting">
    <h2>Reporting & Auditing</h2>
    <div class="feature-box">Compliance Audit Trails</div>
    <div class="feature-box">Customizable Compliance Reports</div>
    <div class="feature-box">Real-time Compliance Dashboards</div>
    <div class="feature-box">Document Management & Storage</div>
    <div class="feature-box">Regulatory Update Notifications</div>
  </section>

  <footer>
    <p>&copy; 2025 Fleet Management Solutions. Ensuring Compliance, Enhancing Performance.</p>
  </footer>
</body>
</html>
