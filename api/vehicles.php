<?php
// api/vehicles.php - Vehicles API endpoints

function handleVehicles($method, $segments) {
    global $conn;

    switch ($method) {
        case 'GET':
            if (!isset($segments[1])) {
                // GET /api/vehicles - List all vehicles
                getAllVehicles();
            } elseif (is_numeric($segments[1])) {
                // GET /api/vehicles/{id} - Get specific vehicle
                getVehicleById($segments[1]);
            } else {
                // GET /api/vehicles/search - Search vehicles
                searchVehicles();
            }
            break;

        case 'POST':
            // POST /api/vehicles - Create new vehicle
            require_role('Dealer'); // Only dealers can add vehicles
            createVehicle();
            break;

        case 'PUT':
            // PUT /api/vehicles/{id} - Update vehicle
            if (!isset($segments[1]) || !is_numeric($segments[1])) {
                http_response_code(400);
                echo json_encode(['error' => 'Vehicle ID required']);
                return;
            }
            require_role('Dealer'); // Only dealers can update vehicles
            updateVehicle($segments[1]);
            break;

        case 'DELETE':
            // DELETE /api/vehicles/{id} - Delete vehicle
            if (!isset($segments[1]) || !is_numeric($segments[1])) {
                http_response_code(400);
                echo json_encode(['error' => 'Vehicle ID required']);
                return;
            }
            require_role('Dealer'); // Only dealers can delete vehicles
            deleteVehicle($segments[1]);
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
            break;
    }
}

function getAllVehicles() {
    global $conn;

    $sql = "SELECT v.*, m.name as manufacturer_name, md.name as model_name
            FROM variants v
            JOIN models md ON v.model_id = md.id
            JOIN manufacturers m ON md.manufacturer_id = m.id
            ORDER BY m.name, md.name, v.variant_name";

    $result = $conn->query($sql);

    if ($result) {
        $vehicles = [];
        while ($row = $result->fetch_assoc()) {
            $vehicles[] = [
                'id' => $row['id'],
                'manufacturer' => $row['manufacturer_name'],
                'model' => $row['model_name'],
                'variant' => $row['variant_name'],
                'fuel_type' => $row['fuel_type'],
                'transmission' => $row['transmission'],
                'power' => $row['power'],
                'mileage' => $row['mileage'],
                'ex_showroom_price' => $row['ex_showroom_price'],
                'on_road_price' => $row['on_road_price']
            ];
        }
        echo json_encode(['vehicles' => $vehicles]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Database error']);
    }
}

function getVehicleById($id) {
    global $conn;

    $sql = "SELECT v.*, m.name as manufacturer_name, md.name as model_name
            FROM variants v
            JOIN models md ON v.model_id = md.id
            JOIN manufacturers m ON md.manufacturer_id = m.id
            WHERE v.id = ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result && $row = $result->fetch_assoc()) {
        $vehicle = [
            'id' => $row['id'],
            'manufacturer' => $row['manufacturer_name'],
            'model' => $row['model_name'],
            'variant' => $row['variant_name'],
            'fuel_type' => $row['fuel_type'],
            'transmission' => $row['transmission'],
            'power' => $row['power'],
            'mileage' => $row['mileage'],
            'ex_showroom_price' => $row['ex_showroom_price'],
            'on_road_price' => $row['on_road_price']
        ];
        echo json_encode(['vehicle' => $vehicle]);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Vehicle not found']);
    }
}

function searchVehicles() {
    global $conn;

    $manufacturer = $_GET['manufacturer'] ?? '';
    $model = $_GET['model'] ?? '';
    $fuel_type = $_GET['fuel_type'] ?? '';
    $min_price = $_GET['min_price'] ?? 0;
    $max_price = $_GET['max_price'] ?? 99999999;

    $sql = "SELECT v.*, m.name as manufacturer_name, md.name as model_name
            FROM variants v
            JOIN models md ON v.model_id = md.id
            JOIN manufacturers m ON md.manufacturer_id = m.id
            WHERE v.ex_showroom_price BETWEEN ? AND ?";

    $params = [$min_price, $max_price];
    $types = "ii";

    if (!empty($manufacturer)) {
        $sql .= " AND m.name LIKE ?";
        $params[] = "%$manufacturer%";
        $types .= "s";
    }

    if (!empty($model)) {
        $sql .= " AND md.name LIKE ?";
        $params[] = "%$model%";
        $types .= "s";
    }

    if (!empty($fuel_type)) {
        $sql .= " AND v.fuel_type = ?";
        $params[] = $fuel_type;
        $types .= "s";
    }

    $sql .= " ORDER BY m.name, md.name, v.variant_name";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();

    $vehicles = [];
    while ($row = $result->fetch_assoc()) {
        $vehicles[] = [
            'id' => $row['id'],
            'manufacturer' => $row['manufacturer_name'],
            'model' => $row['model_name'],
            'variant' => $row['variant_name'],
            'fuel_type' => $row['fuel_type'],
            'transmission' => $row['transmission'],
            'power' => $row['power'],
            'mileage' => $row['mileage'],
            'ex_showroom_price' => $row['ex_showroom_price'],
            'on_road_price' => $row['on_road_price']
        ];
    }

    echo json_encode(['vehicles' => $vehicles, 'count' => count($vehicles)]);
}

function createVehicle() {
    global $conn;

    $data = json_decode(file_get_contents('php://input'), true);

    if (!$data) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON data']);
        return;
    }

    // Validate required fields
    $required = ['model_id', 'variant_name', 'fuel_type', 'transmission'];
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Missing required field: $field"]);
            return;
        }
    }

    $sql = "INSERT INTO variants (model_id, variant_name, fuel_type, transmission, power, mileage, ex_showroom_price, on_road_price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("isssssdd",
        $data['model_id'],
        $data['variant_name'],
        $data['fuel_type'],
        $data['transmission'],
        $data['power'] ?? null,
        $data['mileage'] ?? null,
        $data['ex_showroom_price'] ?? null,
        $data['on_road_price'] ?? null
    );

    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        http_response_code(201);
        echo json_encode(['message' => 'Vehicle created successfully', 'id' => $newId]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create vehicle']);
    }
}

function updateVehicle($id) {
    global $conn;

    $data = json_decode(file_get_contents('php://input'), true);

    if (!$data) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON data']);
        return;
    }

    $sql = "UPDATE variants SET variant_name=?, fuel_type=?, transmission=?, power=?, mileage=?, ex_showroom_price=?, on_road_price=? WHERE id=?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssddi",
        $data['variant_name'] ?? '',
        $data['fuel_type'] ?? '',
        $data['transmission'] ?? '',
        $data['power'] ?? null,
        $data['mileage'] ?? null,
        $data['ex_showroom_price'] ?? null,
        $data['on_road_price'] ?? null,
        $id
    );

    if ($stmt->execute()) {
        echo json_encode(['message' => 'Vehicle updated successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to update vehicle']);
    }
}

function deleteVehicle($id) {
    global $conn;

    $sql = "DELETE FROM variants WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['message' => 'Vehicle deleted successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Vehicle not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to delete vehicle']);
    }
}
?>
