<?php
// Security headers
header("Content-Security-Policy: default-src 'self' https: 'unsafe-inline'");
header("X-Content-Type-Options: nosniff");
header("X-Frame-Options: DENY");
header("X-XSS-Protection: 1; mode=block");

include 'config.php';

// Error handling function
function handleDatabaseError($connection) {
    error_log("Database error: " . $connection->error);
    die("An error occurred. Please try again later.");
}

// Fetch Published Blogs
$sql = "SELECT id, title, content, image_url FROM blogs WHERE status='published' ORDER BY created_at DESC LIMIT 5";
$result = $conn->query($sql);

if (!$result) {
    handleDatabaseError($conn);
}

// Fetch cars using prepared statement
$carQuery = "SELECT id, model_name, image_url, base_price, top_price FROM cars ORDER BY RAND() LIMIT 10";
if ($stmt = $conn->prepare($carQuery)) {
    $stmt->execute();
    $carResult = $stmt->get_result();
} else {
    handleDatabaseError($conn);
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Autopredator - Vehicle Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="style.css">

    <script>
        function searchfunction() {
            const searchTerm = document.getElementById('search-bar').value;
            window.location.href = `car-listing.php?search=${encodeURIComponent(searchTerm)}`;
        }

        function scrollCarCarousel(direction) {
            const carousel = document.getElementById('carCarousel');
            const scrollAmount = carousel.offsetWidth * 0.8;
            carousel.scrollBy({ left: direction * scrollAmount, behavior: 'smooth' });
        }

        function scrollCarousel(direction) {
            document.getElementById("blogCarousel").scrollBy({ left: direction, behavior: 'smooth' });
        }

        function openMenu() {
            document.getElementById("sidebar").classList.add("show-sidebar");
            document.getElementById("overlay").classList.add("show-overlay");
        }

        function closeMenu() {
            document.getElementById("sidebar").classList.remove("show-sidebar");
            document.getElementById("overlay").classList.remove("show-overlay");
        }

        document.addEventListener("DOMContentLoaded", () => {
            document.getElementById("theme-toggle").addEventListener("click", () => {
                document.body.classList.toggle("dark-mode");
            });
        });
    </script>
</head>
<body>
    <!-- Header -->
    <header>
        <h1>Autopredator</h1>
        <button class="menu-btn" onclick="openMenu()">☰ Menu</button>
        <button class="theme-toggle" id="theme-toggle">🌙</button>
    </header>

    <!-- Sidebar Menu -->
    <div id="sidebar" class="sidebar">
        <button class="close-btn" onclick="closeMenu()">✖</button>
        <a href="#home">Home</a>
        <a href="#features">Features</a>
        <a href="#about">About</a>
        <a href="#contact">Contact</a>
    </div>

    <div id="overlay" class="overlay" onclick="closeMenu()"></div>

    <!-- Search bar -->
    <div class="search-container">
        <input type="text" id="search-bar" class="search-bar" placeholder="Search Autopredator">
        <button class="search-button" onclick="searchfunction()">Search</button>
    </div>

    <!-- Hero Section -->
    <section class="hero">
        <h1>Manage Your Vehicles Efficiently</h1>
        <p>Track, maintain, and optimize your vehicle fleet with AI-powered analytics.</p>
        <button class="cta-button">Get Started</button>
    </section>

    <!-- Car Carousel -->
    <section class="container my-5">
        <h2 class="text-center mb-4">Popular Cars</h2>
        <div class="car-carousel" id="carCarousel">
            <?php if ($carResult && $carResult->num_rows > 0): ?>
                <?php while ($car = $carResult->fetch_assoc()): ?>
                    <div class="car-card">
                        <img src="<?= htmlspecialchars($car['image_url']) ?>" alt="<?= htmlspecialchars($car['model_name']) ?>">
                        <div class="car-card-content">
                            <h5><?= htmlspecialchars($car['model_name']) ?></h5>
                            <p>Price: $<?= number_format($car['base_price'], 2) ?> - $<?= number_format($car['top_price'], 2) ?></p>
                            <a href="car-details.php?id=<?= $car['id'] ?>" class="btn btn-primary btn-sm">View Details</a>
                        </div>
                    </div>
                <?php endwhile; ?>
            <?php else: ?>
                <p>No cars found.</p>
            <?php endif; ?>
        </div>
        <div class="carousel-controls">
            <button class="carousel-btn" onclick="scrollCarCarousel(-1)">←</button>
            <button class="carousel-btn" onclick="scrollCarCarousel(1)">→</button>
        </div>
    </section>

    <!-- Fixed Car Listing Link -->
    <a href="car-listing.php?search=&sort=price_asc">Car Listings</a>

    <!-- Rest of the HTML remains unchanged -->

    <footer>
        <p>&copy; 2025 Autopredator. All Rights Reserved.</p>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<?php $conn->close(); ?>
