<?php include 'db_connect.php'; ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Autopredator - Legal Services</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f4f4f4;
            color: #333;
        }
        .header {
            background-color: #007BFF;
            padding: 2rem;
            text-align: center;
            color: white;
            border-radius: 0 0 1rem 1rem;
        }
        .section-icon {
            width: 64px;
            height: 64px;
        }
        .card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transition: transform 0.2s ease-in-out;
        }
        .card:hover {
            transform: translateY(-5px);
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Legal Services</h1>
        <p>Support and compliance solutions for all your vehicle-related legal needs</p>
    </div>

    <div class="container mt-5">
        <div class="row g-4">
            <?php
            // Fetch legal services
            $services_query = "SELECT id, title, description, icon FROM legal_services";
            $services_result = $conn->query($services_query);
            if ($services_result->num_rows > 0) {
                while ($service = $services_result->fetch_assoc()) {
                    echo '<div class="col-md-4">';
                    echo '<div class="card p-4">';
                    if (!empty($service['icon'])) {
                        echo '<img src="' . htmlspecialchars($service['icon']) . '" alt="Service Icon" class="section-icon mb-3">';
                    }
                    echo '<h4>' . htmlspecialchars($service['title']) . '</h4>';
                    echo '<p>' . htmlspecialchars($service['description']) . '</p>';
                    echo '</div>';
                    echo '</div>';
                }
            } else {
                echo '<p>No legal services available.</p>';
            }
            ?>
        </div>
    </div>
</body>
</html>
