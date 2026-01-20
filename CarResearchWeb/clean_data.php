<?php

// Read the original data
$data = json_decode(file_get_contents('mocks/data.json'), true);

// Filter out header entries and renumber s_no
$cleaned = [];
$s_no = 1;
foreach ($data as $car) {
    if (!empty($car['make'])) {
        $car['s_no'] = (string)$s_no;
        $cleaned[] = $car;
        $s_no++;
    }
}

// Write the cleaned data
file_put_contents('mocks/data_cleaned.json', json_encode($cleaned, JSON_PRETTY_PRINT));

echo "Cleaned data saved to mocks/data_cleaned.json\n";
echo "Total cars: " . count($cleaned) . "\n";
