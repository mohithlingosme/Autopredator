<?php
// DB connection
$host = '127.0.0.1';
$db = 'autopredator_unified';
$user = 'root';
$pass = '';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get filters
$search = $_GET['search'] ?? '';
$min_price = $_GET['min_price'] ?? '';
$max_price = $_GET['max_price'] ?? '';
$power = $_GET['power'] ?? '';
$fuel_efficiency = $_GET['fuel_efficiency'] ?? '';
$sort = $_GET['sort'] ?? '';

// Build SQL query
$sql = "SELECT v.variant_name, m.name AS manufacturer, mo.name AS model, v.base_price, v.top_price, v.power, v.fuel_efficiency, v.image_url FROM variants v JOIN models mo ON v.model_id = mo.id JOIN manufacturers m ON mo.manufacturer_id = m.id WHERE 1=1";

// Apply filters
if (!empty($search)) {
    $s = $conn->real_escape_string($search);
    $sql .= " AND (v.variant_name LIKE '%$s%' OR mo.name LIKE '%$s%' OR m.name LIKE '%$s%')";
}
if (is_numeric($min_price)) {
    $sql .= " AND base_price >= " . (float)$min_price;
}
if (is_numeric($max_price)) {
    $sql .= " AND top_price <= " . (float)$max_price;
}
if (!empty($power)) {
    $p = $conn->real_escape_string($power);
    $sql .= " AND power = '$p'";
}
if (!empty($fuel_efficiency)) {
    $f = $conn->real_escape_string($fuel_efficiency);
    $sql .= " AND fuel_efficiency = '$f'";
}

// Sorting
if ($sort == 'price_asc') {
    $sql .= " ORDER BY base_price ASC";
} elseif ($sort == 'price_desc') {
    $sql .= " ORDER BY base_price DESC";
}

// Fetch cars
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Car Listings with Filters</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Car Listings</h1>

    <form method="GET" class="filter-form">
        <input type="text" name="search" placeholder="Search model..." value="<?= htmlspecialchars($search) ?>">

        <input type="number" name="min_price" placeholder="Min Price" value="<?= htmlspecialchars($min_price) ?>">
        <input type="number" name="max_price" placeholder="Max Price" value="<?= htmlspecialchars($max_price) ?>">

        <select name="power">
            <option value="">Select Power</option>
            <option value="100 HP" <?= $power == '100 HP' ? 'selected' : '' ?>>100 HP</option>
            <option value="150 HP" <?= $power == '150 HP' ? 'selected' : '' ?>>150 HP</option>
            <option value="200 HP" <?= $power == '200 HP' ? 'selected' : '' ?>>200 HP</option>
        </select>

        <select name="fuel_efficiency">
            <option value="">Fuel Efficiency</option>
            <option value="20 km/l" <?= $fuel_efficiency == '20 km/l' ? 'selected' : '' ?>>20 km/l</option>
            <option value="25 km/l" <?= $fuel_efficiency == '25 km/l' ? 'selected' : '' ?>>25 km/l</option>
            <option value="30 km/l" <?= $fuel_efficiency == '30 km/l' ? 'selected' : '' ?>>30 km/l</option>
        </select>

        <select name="sort">
            <option value="">Sort by</option>
            <option value="price_asc" <?= $sort == 'price_asc' ? 'selected' : '' ?>>Price Low to High</option>
            <option value="price_desc" <?= $sort == 'price_desc' ? 'selected' : '' ?>>Price High to Low</option>
        </select>

        <button type="submit">Apply Filters</button>
    </form>

    <div class="car-list">
        <?php if ($result && $result->num_rows > 0): ?>
            <?php while ($car = $result->fetch_assoc()): ?>
                <div class="car-card">
                    <img src="<?= htmlspecialchars($car['image_url']) ?>" alt="<?= htmlspecialchars($car['manufacturer'] . ' ' . $car['model'] . ' ' . $car['variant_name']) ?>" class="car-img">
                    <h3><?= htmlspecialchars($car['manufacturer'] . ' ' . $car['model'] . ' ' . $car['variant_name']) ?></h3>
                    <p><strong>Price:</strong> $<?= number_format($car['base_price'], 2) ?> - $<?= number_format($car['top_price'], 2) ?></p>
                    <p><strong>Power:</strong> <?= htmlspecialchars($car['power']) ?></p>
                    <p><strong>Fuel Efficiency:</strong> <?= htmlspecialchars($car['fuel_efficiency']) ?></p>
                </div>
            <?php endwhile; ?>
        <?php else: ?>
            <p>No cars found matching your filters.</p>
        <?php endif; ?>
    </div>
</body>
</html>

<?php $conn->close(); ?>
