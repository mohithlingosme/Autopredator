<?php
// api/insurance.php - Insurance API endpoints

function handleInsurance($method, $segments) {
    global $conn;

    switch ($method) {
        case 'GET':
            if (!isset($segments[1])) {
                // GET /api/insurance - List insurance options
                getInsuranceOptions();
            } elseif ($segments[1] === 'calculate') {
                // GET /api/insurance/calculate - Calculate premium
                calculatePremium();
            } elseif (is_numeric($segments[1])) {
                // GET /api/insurance/{id} - Get specific insurance
                getInsuranceById($segments[1]);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Invalid insurance endpoint']);
            }
            break;

        case 'POST':
            if ($segments[1] === 'quote') {
                // POST /api/insurance/quote - Create insurance quote
                createInsuranceQuote();
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Invalid insurance endpoint']);
            }
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
            break;
    }
}

function getInsuranceOptions() {
    global $conn;

    // This would typically query an insurance_providers table
    // For now, return static insurance options
    $options = [
        [
            'id' => 1,
            'provider' => 'AutoShield Insurance',
            'type' => 'Comprehensive',
            'coverage' => 'Full coverage including theft, accident, and natural disasters',
            'base_premium' => 5000,
            'features' => ['24/7 Roadside Assistance', 'Zero Depreciation', 'Engine Protection']
        ],
        [
            'id' => 2,
            'provider' => 'SafeDrive Insurance',
            'type' => 'Third Party',
            'coverage' => 'Liability coverage for damage to others',
            'base_premium' => 2500,
            'features' => ['Legal Assistance', 'Emergency Coverage']
        ],
        [
            'id' => 3,
            'provider' => 'Premium Auto Insurance',
            'type' => 'Comprehensive Plus',
            'coverage' => 'Full coverage with additional benefits',
            'base_premium' => 7500,
            'features' => ['Personal Accident Cover', 'New Car Replacement', 'Consumable Cover']
        ]
    ];

    echo json_encode(['insurance_options' => $options]);
}

function calculatePremium() {
    // GET parameters for calculation
    $vehicle_value = $_GET['vehicle_value'] ?? 0;
    $vehicle_age = $_GET['vehicle_age'] ?? 0;
    $location = $_GET['location'] ?? 'standard';
    $coverage_type = $_GET['coverage_type'] ?? 'comprehensive';
    $driver_age = $_GET['driver_age'] ?? 30;
    $driving_experience = $_GET['driving_experience'] ?? 5;

    if ($vehicle_value <= 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Valid vehicle value required']);
        return;
    }

    // Basic premium calculation logic
    $base_rate = 0.05; // 5% of vehicle value

    switch ($coverage_type) {
        case 'comprehensive':
            $coverage_multiplier = 1.0;
            break;
        case 'third_party':
            $coverage_multiplier = 0.4;
            break;
        default:
            $coverage_multiplier = 0.8;
    }

    // Age factors
    $age_factor = 1.0;
    if ($driver_age < 25) $age_factor = 1.5;
    elseif ($driver_age > 60) $age_factor = 1.2;

    // Experience factor
    $experience_factor = 1.0;
    if ($driving_experience < 2) $experience_factor = 1.3;
    elseif ($driving_experience > 10) $experience_factor = 0.9;

    // Location factor
    $location_factor = 1.0;
    if ($location === 'high_risk') $location_factor = 1.4;
    elseif ($location === 'low_risk') $location_factor = 0.8;

    // Vehicle age factor
    $age_vehicle_factor = 1.0 + ($vehicle_age * 0.1); // 10% increase per year

    // Calculate premium
    $base_premium = $vehicle_value * $base_rate;
    $final_premium = $base_premium * $coverage_multiplier * $age_factor * $experience_factor * $location_factor * $age_vehicle_factor;

    // Round to nearest 100
    $final_premium = round($final_premium / 100) * 100;

    $calculation = [
        'vehicle_value' => $vehicle_value,
        'coverage_type' => $coverage_type,
        'driver_age' => $driver_age,
        'driving_experience' => $driving_experience,
        'location' => $location,
        'vehicle_age' => $vehicle_age,
        'base_premium' => $base_premium,
        'final_premium' => $final_premium,
        'breakdown' => [
            'coverage_multiplier' => $coverage_multiplier,
            'age_factor' => $age_factor,
            'experience_factor' => $experience_factor,
            'location_factor' => $location_factor,
            'vehicle_age_factor' => $age_vehicle_factor
        ]
    ];

    echo json_encode(['premium_calculation' => $calculation]);
}

function getInsuranceById($id) {
    // This would query a specific insurance policy
    // For now, return mock data
    $policies = [
        1 => [
            'id' => 1,
            'policy_number' => 'AS2024001',
            'provider' => 'AutoShield Insurance',
            'type' => 'Comprehensive',
            'vehicle_make' => 'Maruti Suzuki',
            'vehicle_model' => 'Brezza',
            'vehicle_year' => 2023,
            'coverage_amount' => 850000,
            'premium_amount' => 5200,
            'start_date' => '2024-01-01',
            'end_date' => '2025-01-01',
            'status' => 'active'
        ]
    ];

    if (isset($policies[$id])) {
        echo json_encode(['insurance_policy' => $policies[$id]]);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Insurance policy not found']);
    }
}

function createInsuranceQuote() {
    global $conn;

    $data = json_decode(file_get_contents('php://input'), true);

    if (!$data) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON data']);
        return;
    }

    // Validate required fields
    $required = ['vehicle_value', 'vehicle_make', 'vehicle_model', 'driver_name', 'driver_email'];
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Missing required field: $field"]);
            return;
        }
    }

    // Calculate premium using the same logic as calculatePremium
    $vehicle_value = $data['vehicle_value'];
    $coverage_type = $data['coverage_type'] ?? 'comprehensive';
    $driver_age = $data['driver_age'] ?? 30;
    $driving_experience = $data['driving_experience'] ?? 5;
    $location = $data['location'] ?? 'standard';
    $vehicle_age = $data['vehicle_age'] ?? 0;

    $base_rate = 0.05;
    $coverage_multiplier = $coverage_type === 'comprehensive' ? 1.0 : ($coverage_type === 'third_party' ? 0.4 : 0.8);
    $age_factor = ($driver_age < 25) ? 1.5 : (($driver_age > 60) ? 1.2 : 1.0);
    $experience_factor = ($driving_experience < 2) ? 1.3 : (($driving_experience > 10) ? 0.9 : 1.0);
    $location_factor = ($location === 'high_risk') ? 1.4 : (($location === 'low_risk') ? 0.8 : 1.0);
    $age_vehicle_factor = 1.0 + ($vehicle_age * 0.1);

    $base_premium = $vehicle_value * $base_rate;
    $final_premium = round(($base_premium * $coverage_multiplier * $age_factor * $experience_factor * $location_factor * $age_vehicle_factor) / 100) * 100;

    // In a real application, this would be stored in a database
    // For now, just return the quote
    $quote = [
        'quote_id' => 'Q' . time() . rand(100, 999),
        'vehicle_make' => $data['vehicle_make'],
        'vehicle_model' => $data['vehicle_model'],
        'vehicle_value' => $vehicle_value,
        'vehicle_age' => $vehicle_age,
        'driver_name' => $data['driver_name'],
        'driver_email' => $data['driver_email'],
        'driver_age' => $driver_age,
        'driving_experience' => $driving_experience,
        'location' => $location,
        'coverage_type' => $coverage_type,
        'calculated_premium' => $final_premium,
        'quote_date' => date('Y-m-d H:i:s'),
        'valid_until' => date('Y-m-d H:i:s', strtotime('+30 days'))
    ];

    http_response_code(201);
    echo json_encode(['insurance_quote' => $quote, 'message' => 'Quote generated successfully']);
}
?>
