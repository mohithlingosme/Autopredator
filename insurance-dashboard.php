<?php
session_start();
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit;
}
?>
<?php
// 🔧 Mock Data (Replace with DB fetch later)

// Vehicle, Owner, and Policy Data from previous code...
// Same as before, keeping short here for brevity
$vehicle = [
    'make' => 'Toyota', 'model' => 'Fortuner', 'variant' => '2.8L Diesel AT',
    'reg_number' => 'MH12AB1234', 'fuel_type' => 'Diesel', 'transmission' => 'Automatic',
    'color' => 'White', 'vin' => 'XYZ1234567890VIN', 'engine_number' => 'ENG9876543210',
];

$owner = [
    'name' => 'John Doe', 'age' => 35, 'contact' => '9876543210', 'address' => '123, Palm Grove, Mumbai',
    'nominee_name' => 'Jane Doe', 'nominee_relation' => 'Wife'
];

$policy = [
    'policy_number' => 'ICICI-POL-2024-6789', 'provider' => 'ICICI Lombard',
    'provider_logo' => 'assets/img/icici-logo.png', 'start_date' => '2024-01-01',
    'end_date' => '2025-01-01', 'pdf_url' => 'downloads/policy.pdf', 'claim_url' => 'file-claim.php',
    'support_url' => 'support.php', 'coverage_type' => 'Comprehensive', 'idv' => '15,00,000',
    'premium' => '32,500', 'addons' => ['Zero Depreciation', 'RSA', 'Engine Protect'],
    'deductibles' => '₹1,000', 'ncb' => '2 Years'
];

$garages = [
    ['name' => 'SpeedFix Auto Garage', 'location' => 'Mumbai', 'distance' => '2.4 km', 'rating' => 4.7],
    ['name' => 'AutoCare Works', 'location' => 'Thane', 'distance' => '8.1 km', 'rating' => 4.5],
    ['name' => 'Mega Motors', 'location' => 'Navi Mumbai', 'distance' => '12.7 km', 'rating' => 4.2],
];

$claims = [
    ['date' => '2023-08-01', 'amount' => '12,000', 'status' => 'Settled'],
    ['date' => '2024-03-15', 'amount' => 'Pending', 'status' => 'Under Review'],
];

$transactions = [
    ['date' => '2024-01-01', 'type' => 'Initial Premium Payment', 'amount' => '₹32,500'],
    ['date' => '2024-07-01', 'type' => 'Add-on: RSA Upgrade', 'amount' => '₹1,500'],
];

$faqs = [
    ['q' => 'What is IDV?', 'a' => 'IDV stands for Insured Declared Value — the current market value of your vehicle.'],
    ['q' => 'Can I renew before expiry?', 'a' => 'Yes, renewal is allowed up to 90 days before policy expiry.'],
];
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Insurance Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background: #f5f7fa; font-family: 'Segoe UI', sans-serif; }
    .dashboard-container { max-width: 1000px; margin: 40px auto; padding: 30px; background: white; border-radius: 12px; box-shadow: 0 0 20px rgba(0,0,0,0.05); }
    .section-title { border-bottom: 1px solid #ddd; padding-bottom: 5px; margin-bottom: 20px; font-size: 1.4rem; font-weight: bold; }
    .badge-addon { background: #007bff; color: white; margin-right: 6px; }
    .card-faq { margin-bottom: 15px; }
  </style>
</head>
<body>

<div class="dashboard-container">

  <!-- ✅ SECTION 1: Header -->
  <div class="text-center mb-4">
    <img src="<?= $policy['provider_logo'] ?>" alt="<?= $policy['provider'] ?>" height="60" class="mb-2">
    <h2><?= $vehicle['make'] . ' ' . $vehicle['model'] ?> - <?= $vehicle['reg_number'] ?></h2>
    <p><strong>Policy No:</strong> <?= $policy['policy_number'] ?></p>
    <p><strong>Valid:</strong> <?= $policy['start_date'] ?> to <?= $policy['end_date'] ?></p>
    <a href="<?= $policy['pdf_url'] ?>" class="btn btn-primary btn-sm" target="_blank">📄 Download Policy</a>
    <a href="<?= $policy['claim_url'] ?>" class="btn btn-warning btn-sm">🛠️ File a Claim</a>
    <a href="<?= $policy['support_url'] ?>" class="btn btn-outline-dark btn-sm">🚨 Need Help?</a>
  </div>

  <!-- SECTION 2: Vehicle -->
  <div class="mb-4">
    <div class="section-title">Vehicle Details</div>
    <ul class="list-group">
      <li class="list-group-item"><strong>Make/Model:</strong> <?= $vehicle['make'] ?> <?= $vehicle['model'] ?> (<?= $vehicle['variant'] ?>)</li>
      <li class="list-group-item"><strong>Fuel:</strong> <?= $vehicle['fuel_type'] ?> | <strong>Transmission:</strong> <?= $vehicle['transmission'] ?></li>
      <li class="list-group-item"><strong>VIN:</strong> <?= $vehicle['vin'] ?> | <strong>Engine No:</strong> <?= $vehicle['engine_number'] ?></li>
      <li class="list-group-item"><strong>Color:</strong> <?= $vehicle['color'] ?></li>
    </ul>
  </div>

  <!-- SECTION 3: Owner & Nominee -->
  <div class="mb-4">
    <div class="section-title">Owner & Nominee</div>
    <ul class="list-group">
      <li class="list-group-item"><strong>Owner:</strong> <?= $owner['name'] ?> (<?= $owner['age'] ?> yrs), <?= $owner['contact'] ?></li>
      <li class="list-group-item"><strong>Address:</strong> <?= $owner['address'] ?></li>
      <li class="list-group-item"><strong>Nominee:</strong> <?= $owner['nominee_name'] ?> (<?= $owner['nominee_relation'] ?>)</li>
    </ul>
  </div>

  <!-- SECTION 4: Policy Coverage -->
  <div class="mb-4">
    <div class="section-title">Coverage Details</div>
    <ul class="list-group">
      <li class="list-group-item"><strong>Type:</strong> <?= $policy['coverage_type'] ?></li>
      <li class="list-group-item"><strong>IDV:</strong> ₹<?= $policy['idv'] ?> | <strong>Premium:</strong> ₹<?= $policy['premium'] ?></li>
      <li class="list-group-item"><strong>Deductibles:</strong> <?= $policy['deductibles'] ?> | <strong>NCB:</strong> <?= $policy['ncb'] ?></li>
      <li class="list-group-item"><strong>Add-ons:</strong>
        <?php foreach ($policy['addons'] as $addon): ?>
          <span class="badge badge-addon"><?= $addon ?></span>
        <?php endforeach; ?>
      </li>
    </ul>
  </div>

  <!-- ✅ SECTION 5: Cashless Garages -->
  <div class="mb-4">
    <div class="section-title">Cashless Garage Network</div>
    <ul class="list-group">
      <?php foreach ($garages as $garage): ?>
        <li class="list-group-item d-flex justify-content-between align-items-center">
          <div>
            <strong><?= $garage['name'] ?></strong><br>
            <?= $garage['location'] ?> – <?= $garage['distance'] ?>
          </div>
          <span class="badge bg-success">⭐ <?= $garage['rating'] ?></span>
        </li>
      <?php endforeach; ?>
    </ul>
  </div>

  <!-- ✅ SECTION 6: Claim History -->
  <div class="mb-4">
    <div class="section-title">Claim History</div>
    <table class="table table-bordered">
      <thead>
        <tr><th>Date</th><th>Amount</th><th>Status</th></tr>
      </thead>
      <tbody>
        <?php foreach ($claims as $claim): ?>
          <tr>
            <td><?= $claim['date'] ?></td>
            <td><?= $claim['amount'] ?></td>
            <td><?= $claim['status'] ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <a href="claims.php" class="btn btn-sm btn-outline-primary">View All Claims</a>
  </div>

  <!-- ✅ SECTION 7: Transactions -->
  <div class="mb-4">
    <div class="section-title">Policy Transactions</div>
    <table class="table table-striped">
      <thead>
        <tr><th>Date</th><th>Type</th><th>Amount</th></tr>
      </thead>
      <tbody>
        <?php foreach ($transactions as $tx): ?>
          <tr>
            <td><?= $tx['date'] ?></td>
            <td><?= $tx['type'] ?></td>
            <td><?= $tx['amount'] ?></td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>

  <!-- ✅ SECTION 8: FAQ & Support -->
  <div class="mb-4">
    <div class="section-title">FAQs & Support</div>
    <?php foreach ($faqs as $faq): ?>
      <div class="card card-faq">
        <div class="card-header"><strong>Q:</strong> <?= $faq['q'] ?></div>
        <div class="card-body"><strong>A:</strong> <?= $faq['a'] ?></div>
      </div>
    <?php endforeach; ?>
    <a href="blogs.php?category=insurance" class="btn btn-link">Read More Articles →</a>
  </div>

</div>

</body>
</html>
